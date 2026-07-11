// bot.swift
import Foundation

// Simple Telegram bot using URLSession (no external library)
// Requires BOT_TOKEN environment variable

guard let token = ProcessInfo.processInfo.environment["BOT_TOKEN"], !token.isEmpty else {
    print("BOT_TOKEN environment variable not set")
    exit(1)
}

let apiURL = "https://api.telegram.org/bot\(token)/"

struct Update: Codable {
    let update_id: Int
    let message: Message?
    let callback_query: CallbackQuery?
}

struct Message: Codable {
    let message_id: Int
    let chat: Chat
    let text: String?
}

struct Chat: Codable {
    let id: Int
}

struct CallbackQuery: Codable {
    let id: String
    let data: String?
    let message: Message?
}

struct SendMessage: Codable {
    let chat_id: Int
    let text: String
    let reply_markup: InlineKeyboardMarkup?
}

struct InlineKeyboardMarkup: Codable {
    let inline_keyboard: [[InlineKeyboardButton]]
}

struct InlineKeyboardButton: Codable {
    let text: String
    let callback_data: String
}

var stats = (messages: 0, commands: 0)

func sendMessage(chatId: Int, text: String, keyboard: InlineKeyboardMarkup? = nil) {
    var request = URLRequest(url: URL(string: apiURL + "sendMessage")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var payload: [String: Any] = ["chat_id": chatId, "text": text]
    if let keyboard = keyboard {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(keyboard),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            payload["reply_markup"] = json
        }
    }
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
    let task = URLSession.shared.dataTask(with: request) { _, _, _ in }
    task.resume()
}

func handleMessage(_ message: Message) {
    guard let text = message.text else { return }
    let chatId = message.chat.id

    if text.hasPrefix("/") {
        let parts = text.split(separator: " ", maxSplits: 1).map(String.init)
        let cmd = parts[0].lowercased()
        let arg = parts.count > 1 ? parts[1] : ""

        switch cmd {
        case "/start":
            let keyboard = InlineKeyboardMarkup(inline_keyboard: [
                [
                    InlineKeyboardButton(text: "📖 Help", callback_data: "help"),
                    InlineKeyboardButton(text: "⏰ Time", callback_data: "time")
                ],
                [
                    InlineKeyboardButton(text: "📊 Stats", callback_data: "stats")
                ]
            ])
            sendMessage(chatId: chatId, text: "Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.", keyboard: keyboard)
        case "/help":
            sendMessage(chatId: chatId, text: "Available commands:\n/start - Welcome message\n/help - Show this help\n/echo <text> - Echo back your text\n/time - Show current server time\n/stats - Show usage statistics\n/about - About this bot")
        case "/echo":
            stats.messages += 1
            if arg.isEmpty {
                sendMessage(chatId: chatId, text: "Please provide text after /echo")
            } else {
                sendMessage(chatId: chatId, text: "🔊 Echo: \(arg)")
            }
        case "/time":
            stats.commands += 1
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let now = formatter.string(from: Date())
            sendMessage(chatId: chatId, text: "🕐 Current time: \(now)")
        case "/stats":
            stats.commands += 1
            sendMessage(chatId: chatId, text: "📊 Statistics:\n  Total messages: \(stats.messages)\n  Commands used: \(stats.commands)")
        case "/about":
            sendMessage(chatId: chatId, text: "🤖 Telegram Echo Bot\nBuilt with Swift URLSession\nMIT License")
        default:
            sendMessage(chatId: chatId, text: "Unknown command: \(cmd). Use /help")
        }
    } else {
        stats.messages += 1
        sendMessage(chatId: chatId, text: "🔊 You said: \(text)")
    }
}

func handleCallback(_ query: CallbackQuery) {
    guard let data = query.data, let message = query.message else { return }
    let chatId = message.chat.id

    switch data {
    case "help":
        sendMessage(chatId: chatId, text: "Available commands: /help, /start, /echo, /time, /stats, /about")
    case "time":
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let now = formatter.string(from: Date())
        sendMessage(chatId: chatId, text: "🕐 Current time: \(now)")
    case "stats":
        sendMessage(chatId: chatId, text: "📊 Statistics:\n  Total messages: \(stats.messages)\n  Commands used: \(stats.commands)")
    default:
        break
    }
}

func pollUpdates(offset: Int = 0) {
    let url = URL(string: apiURL + "getUpdates?offset=\(offset)&timeout=10")!
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) { pollUpdates(offset: offset) }
            return
        }
        do {
            let updates = try JSONDecoder().decode([Update].self, from: data)
            var newOffset = offset
            for update in updates {
                newOffset = update.update_id + 1
                if let message = update.message {
                    handleMessage(message)
                }
                if let callback = update.callback_query {
                    handleCallback(callback)
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { pollUpdates(offset: newOffset) }
        } catch {
            print("JSON decode error: \(error)")
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { pollUpdates(offset: offset) }
        }
    }
    task.resume()
}

print("Bot started. Press Ctrl+C to stop.")
pollUpdates()
RunLoop.main.run()
