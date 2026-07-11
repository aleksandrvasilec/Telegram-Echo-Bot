# bot.rb
require 'telegram/bot'
require 'time'

TOKEN = ENV['BOT_TOKEN']
unless TOKEN
  puts 'BOT_TOKEN environment variable not set'
  exit 1
end

$stats = { messages: 0, commands: 0 }

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      chat_id = message.chat.id
      text = message.text

      next if text.nil?

      if text.start_with?('/')
        parts = text.split(' ', 2)
        cmd = parts[0].downcase
        arg = parts[1] || ''

        case cmd
        when '/start'
          bot.api.send_message(
            chat_id: chat_id,
            text: "Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.",
            reply_markup: {
              inline_keyboard: [
                [{ text: '📖 Help', callback_data: 'help' }, { text: '⏰ Time', callback_data: 'time' }],
                [{ text: '📊 Stats', callback_data: 'stats' }]
              ]
            }
          )
        when '/help'
          help_text = "Available commands:\n/start - Welcome message\n/help - Show this help\n/echo <text> - Echo back your text\n/time - Show current server time\n/stats - Show usage statistics\n/about - About this bot"
          bot.api.send_message(chat_id: chat_id, text: help_text)
        when '/echo'
          $stats[:messages] += 1
          if arg.empty?
            bot.api.send_message(chat_id: chat_id, text: "Please provide text after /echo")
          else
            bot.api.send_message(chat_id: chat_id, text: "🔊 Echo: #{arg}")
          end
        when '/time'
          $stats[:commands] += 1
          now = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')
          bot.api.send_message(chat_id: chat_id, text: "🕐 Current time: #{now}")
        when '/stats'
          $stats[:commands] += 1
          txt = "📊 Statistics:\n  Total messages: #{$stats[:messages]}\n  Commands used: #{$stats[:commands]}"
          bot.api.send_message(chat_id: chat_id, text: txt)
        when '/about'
          bot.api.send_message(chat_id: chat_id, text: "🤖 Telegram Echo Bot\nBuilt with telegram-bot-ruby\nMIT License")
        else
          bot.api.send_message(chat_id: chat_id, text: "Unknown command: #{cmd}. Use /help")
        end
      else
        $stats[:messages] += 1
        bot.api.send_message(chat_id: chat_id, text: "🔊 You said: #{text}")
      end

    when Telegram::Bot::Types::CallbackQuery
      chat_id = message.from.id
      data = message.data
      bot.api.answer_callback_query(callback_query_id: message.id)

      case data
      when 'help'
        bot.api.send_message(chat_id: chat_id, text: "Available commands: /help, /start, /echo, /time, /stats, /about")
      when 'time'
        now = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')
        bot.api.send_message(chat_id: chat_id, text: "🕐 Current time: #{now}")
      when 'stats'
        txt = "📊 Statistics:\n  Total messages: #{$stats[:messages]}\n  Commands used: #{$stats[:commands]}"
        bot.api.send_message(chat_id: chat_id, text: txt)
      end
    end
  end
end
