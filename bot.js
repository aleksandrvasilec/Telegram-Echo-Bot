// bot.js
const TelegramBot = require('node-telegram-bot-api');

const token = process.env.BOT_TOKEN;
if (!token) {
    console.error('BOT_TOKEN environment variable not set');
    process.exit(1);
}

const bot = new TelegramBot(token, { polling: true });

const stats = { messages: 0, commands: 0 };

// Command: /start
bot.onText(/\/start/, (msg) => {
    const chatId = msg.chat.id;
    const opts = {
        reply_markup: {
            inline_keyboard: [
                [{ text: '📖 Help', callback_data: 'help' },
                 { text: '⏰ Time', callback_data: 'time' }],
                [{ text: '📊 Stats', callback_data: 'stats' }]
            ]
        }
    };
    bot.sendMessage(chatId, 'Hello! I\'m an Echo Bot. Send me anything and I\'ll echo it back. Use /help for commands.', opts);
});

// Command: /help
bot.onText(/\/help/, (msg) => {
    const chatId = msg.chat.id;
    const text = 'Available commands:\n' +
        '/start - Welcome message\n' +
        '/help - Show this help\n' +
        '/echo <text> - Echo back your text\n' +
        '/time - Show current server time\n' +
        '/stats - Show usage statistics\n' +
        '/about - About this bot';
    bot.sendMessage(chatId, text);
});

// Command: /echo
bot.onText(/\/echo (.+)/, (msg, match) => {
    const chatId = msg.chat.id;
    stats.messages++;
    const text = match[1];
    bot.sendMessage(chatId, `🔊 Echo: ${text}`);
});

// Command: /time
bot.onText(/\/time/, (msg) => {
    const chatId = msg.chat.id;
    stats.commands++;
    const now = new Date().toISOString().replace('T', ' ').slice(0, 19) + ' UTC';
    bot.sendMessage(chatId, `🕐 Current time: ${now}`);
});

// Command: /stats
bot.onText(/\/stats/, (msg) => {
    const chatId = msg.chat.id;
    stats.commands++;
    const text = `📊 Statistics:\n  Total messages: ${stats.messages}\n  Commands used: ${stats.commands}`;
    bot.sendMessage(chatId, text);
});

// Command: /about
bot.onText(/\/about/, (msg) => {
    const chatId = msg.chat.id;
    bot.sendMessage(chatId, '🤖 Telegram Echo Bot\nBuilt with node-telegram-bot-api\nMIT License');
});

// Handle text messages
bot.on('message', (msg) => {
    const chatId = msg.chat.id;
    const text = msg.text;
    if (!text || text.startsWith('/')) return;
    stats.messages++;
    bot.sendMessage(chatId, `🔊 You said: ${text}`);
});

// Callback queries for inline keyboard
bot.on('callback_query', (query) => {
    const chatId = query.message.chat.id;
    const data = query.data;
    bot.answerCallbackQuery(query.id);
    if (data === 'help') {
        bot.sendMessage(chatId, 'Available commands: /help, /start, /echo, /time, /stats, /about');
    } else if (data === 'time') {
        const now = new Date().toISOString().replace('T', ' ').slice(0, 19) + ' UTC';
        bot.sendMessage(chatId, `🕐 Current time: ${now}`);
    } else if (data === 'stats') {
        const text = `📊 Statistics:\n  Total messages: ${stats.messages}\n  Commands used: ${stats.commands}`;
        bot.sendMessage(chatId, text);
    }
});

console.log('Bot started. Press Ctrl+C to stop.');
