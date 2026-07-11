// Bot.cs
using System;
using System.Threading.Tasks;
using Telegram.Bot;
using Telegram.Bot.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using Telegram.Bot.Types.ReplyMarkups;

class Bot
{
    private static readonly TelegramBotClient BotClient;
    private static readonly Stats Stats = new Stats();

    static Bot()
    {
        string token = Environment.GetEnvironmentVariable("BOT_TOKEN");
        if (string.IsNullOrEmpty(token))
            throw new Exception("BOT_TOKEN environment variable not set");
        BotClient = new TelegramBotClient(token);
    }

    class Stats
    {
        public int Messages { get; set; }
        public int Commands { get; set; }
    }

    static async Task Main()
    {
        using var cts = new CancellationTokenSource();
        var receiverOptions = new ReceiverOptions
        {
            AllowedUpdates = new[] { UpdateType.Message, UpdateType.CallbackQuery }
        };

        BotClient.StartReceiving(
            HandleUpdateAsync,
            HandlePollingErrorAsync,
            receiverOptions,
            cancellationToken: cts.Token
        );

        Console.WriteLine("Bot started. Press Ctrl+C to stop.");
        await Task.Delay(-1);
    }

    static async Task HandleUpdateAsync(ITelegramBotClient client, Update update, CancellationToken cancellationToken)
    {
        if (update.Message is Message msg)
        {
            long chatId = msg.Chat.Id;
            string? text = msg.Text;

            if (text == null) return;

            if (text.StartsWith("/"))
            {
                await HandleCommand(client, chatId, text, cancellationToken);
                return;
            }

            Stats.Messages++;
            await client.SendTextMessageAsync(chatId, $"🔊 You said: {text}", cancellationToken: cancellationToken);
        }
        else if (update.CallbackQuery is CallbackQuery query)
        {
            await client.AnswerCallbackQueryAsync(query.Id, cancellationToken: cancellationToken);
            long chatId = query.Message.Chat.Id;
            string data = query.Data;

            if (data == "help")
                await client.SendTextMessageAsync(chatId, "Available commands: /help, /start, /echo, /time, /stats, /about", cancellationToken: cancellationToken);
            else if (data == "time")
            {
                string now = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss") + " UTC";
                await client.SendTextMessageAsync(chatId, $"🕐 Current time: {now}", cancellationToken: cancellationToken);
            }
            else if (data == "stats")
            {
                string text = $"📊 Statistics:\n  Total messages: {Stats.Messages}\n  Commands used: {Stats.Commands}";
                await client.SendTextMessageAsync(chatId, text, cancellationToken: cancellationToken);
            }
        }
    }

    static async Task HandleCommand(ITelegramBotClient client, long chatId, string text, CancellationToken cancellationToken)
    {
        string[] parts = text.Split(' ', 2);
        string cmd = parts[0].ToLower();
        string arg = parts.Length > 1 ? parts[1] : "";

        switch (cmd)
        {
            case "/start":
                var keyboard = new InlineKeyboardMarkup(new[]
                {
                    new[]
                    {
                        InlineKeyboardButton.WithCallbackData("📖 Help", "help"),
                        InlineKeyboardButton.WithCallbackData("⏰ Time", "time")
                    },
                    new[] { InlineKeyboardButton.WithCallbackData("📊 Stats", "stats") }
                });
                await client.SendTextMessageAsync(chatId,
                    "Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.",
                    replyMarkup: keyboard, cancellationToken: cancellationToken);
                break;

            case "/help":
                string help = "Available commands:\n/start - Welcome message\n/help - Show this help\n/echo <text> - Echo back your text\n/time - Show current server time\n/stats - Show usage statistics\n/about - About this bot";
                await client.SendTextMessageAsync(chatId, help, cancellationToken: cancellationToken);
                break;

            case "/echo":
                Stats.Messages++;
                if (string.IsNullOrEmpty(arg))
                {
                    await client.SendTextMessageAsync(chatId, "Please provide text after /echo", cancellationToken: cancellationToken);
                    return;
                }
                await client.SendTextMessageAsync(chatId, $"🔊 Echo: {arg}", cancellationToken: cancellationToken);
                break;

            case "/time":
                Stats.Commands++;
                string now = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss") + " UTC";
                await client.SendTextMessageAsync(chatId, $"🕐 Current time: {now}", cancellationToken: cancellationToken);
                break;

            case "/stats":
                Stats.Commands++;
                string statsText = $"📊 Statistics:\n  Total messages: {Stats.Messages}\n  Commands used: {Stats.Commands}";
                await client.SendTextMessageAsync(chatId, statsText, cancellationToken: cancellationToken);
                break;

            case "/about":
                await client.SendTextMessageAsync(chatId, "🤖 Telegram Echo Bot\nBuilt with Telegram.Bot\nMIT License", cancellationToken: cancellationToken);
                break;

            default:
                await client.SendTextMessageAsync(chatId, $"Unknown command: {cmd}. Use /help", cancellationToken: cancellationToken);
                break;
        }
    }

    static Task HandlePollingErrorAsync(ITelegramBotClient client, Exception exception, CancellationToken cancellationToken)
    {
        Console.WriteLine($"Error: {exception.Message}");
        return Task.CompletedTask;
    }
}
