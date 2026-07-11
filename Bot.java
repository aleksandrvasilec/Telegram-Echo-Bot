// Bot.java
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Message;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.InlineKeyboardMarkup;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.buttons.InlineKeyboardButton;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class Bot extends TelegramLongPollingBot {
    private static final String BOT_TOKEN = System.getenv("BOT_TOKEN");
    private static final String BOT_USERNAME = "YourBotUsername"; // replace or use env

    private static class Stats {
        int messages = 0;
        int commands = 0;
    }
    private final Stats stats = new Stats();

    @Override
    public String getBotToken() {
        if (BOT_TOKEN == null || BOT_TOKEN.isEmpty()) {
            throw new RuntimeException("BOT_TOKEN environment variable not set");
        }
        return BOT_TOKEN;
    }

    @Override
    public String getBotUsername() {
        return BOT_USERNAME;
    }

    @Override
    public void onUpdateReceived(Update update) {
        if (update.hasMessage()) {
            Message msg = update.getMessage();
            long chatId = msg.getChatId();
            String text = msg.getText();

            if (text == null) return;

            if (text.startsWith("/")) {
                handleCommand(chatId, text);
                return;
            }

            stats.messages++;
            sendMessage(chatId, "🔊 You said: " + text);
        } else if (update.hasCallbackQuery()) {
            String data = update.getCallbackQuery().getData();
            long chatId = update.getCallbackQuery().getMessage().getChatId();
            if (data.equals("help")) {
                sendMessage(chatId, "Available commands: /help, /start, /echo, /time, /stats, /about");
            } else if (data.equals("time")) {
                String now = ZonedDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z"));
                sendMessage(chatId, "🕐 Current time: " + now);
            } else if (data.equals("stats")) {
                String txt = "📊 Statistics:\n  Total messages: " + stats.messages + "\n  Commands used: " + stats.commands;
                sendMessage(chatId, txt);
            }
        }
    }

    private void handleCommand(long chatId, String text) {
        String[] parts = text.split(" ", 2);
        String cmd = parts[0].toLowerCase();
        String arg = parts.length > 1 ? parts[1] : "";

        switch (cmd) {
            case "/start":
                InlineKeyboardMarkup keyboard = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rows = new ArrayList<>();
                List<InlineKeyboardButton> row1 = new ArrayList<>();
                row1.add(InlineKeyboardButton.builder().text("📖 Help").callbackData("help").build());
                row1.add(InlineKeyboardButton.builder().text("⏰ Time").callbackData("time").build());
                List<InlineKeyboardButton> row2 = new ArrayList<>();
                row2.add(InlineKeyboardButton.builder().text("📊 Stats").callbackData("stats").build());
                rows.add(row1); rows.add(row2);
                keyboard.setKeyboard(rows);
                sendMessage(chatId, "Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.", keyboard);
                break;

            case "/help":
                String help = "Available commands:\n/start - Welcome message\n/help - Show this help\n/echo <text> - Echo back your text\n/time - Show current server time\n/stats - Show usage statistics\n/about - About this bot";
                sendMessage(chatId, help);
                break;

            case "/echo":
                stats.messages++;
                if (arg.isEmpty()) {
                    sendMessage(chatId, "Please provide text after /echo");
                    return;
                }
                sendMessage(chatId, "🔊 Echo: " + arg);
                break;

            case "/time":
                stats.commands++;
                String now = ZonedDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z"));
                sendMessage(chatId, "🕐 Current time: " + now);
                break;

            case "/stats":
                stats.commands++;
                String txt = "📊 Statistics:\n  Total messages: " + stats.messages + "\n  Commands used: " + stats.commands;
                sendMessage(chatId, txt);
                break;

            case "/about":
                sendMessage(chatId, "🤖 Telegram Echo Bot\nBuilt with TelegramBots\nMIT License");
                break;

            default:
                sendMessage(chatId, "Unknown command: " + cmd + ". Use /help");
        }
    }

    private void sendMessage(long chatId, String text) {
        SendMessage msg = new SendMessage();
        msg.setChatId(chatId);
        msg.setText(text);
        try {
            execute(msg);
        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    private void sendMessage(long chatId, String text, InlineKeyboardMarkup keyboard) {
        SendMessage msg = new SendMessage();
        msg.setChatId(chatId);
        msg.setText(text);
        msg.setReplyMarkup(keyboard);
        try {
            execute(msg);
        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        if (System.getenv("BOT_TOKEN") == null) {
            System.err.println("BOT_TOKEN environment variable not set");
            System.exit(1);
        }
        try {
            TelegramBotsApi botsApi = new TelegramBotsApi(DefaultBotSession.class);
            botsApi.registerBot(new Bot());
            System.out.println("Bot started. Press Ctrl+C to stop.");
        } catch (TelegramApiException e) {
            e.printStackTrace();
        }
    }
}
