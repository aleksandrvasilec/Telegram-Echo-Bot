# bot.py
import os
import logging
from datetime import datetime
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Bot token from environment variable
TOKEN = os.environ.get("BOT_TOKEN")
if not TOKEN:
    raise ValueError("No BOT_TOKEN set. Set environment variable BOT_TOKEN.")

# Statistics
stats = {"messages": 0, "commands": 0}

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        [InlineKeyboardButton("📖 Help", callback_data="help"),
         InlineKeyboardButton("⏰ Time", callback_data="time")],
        [InlineKeyboardButton("📊 Stats", callback_data="stats")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "Hello! I'm an Echo Bot. Send me anything and I'll echo it back.\n"
        "Use /help for commands.",
        reply_markup=reply_markup
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = (
        "Available commands:\n"
        "/start - Welcome message\n"
        "/help - Show this help\n"
        "/echo <text> - Echo back your text\n"
        "/time - Show current server time\n"
        "/stats - Show usage statistics\n"
        "/about - About this bot"
    )
    await update.message.reply_text(text)

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    stats["messages"] += 1
    text = " ".join(context.args)
    if not text:
        await update.message.reply_text("Please provide text after /echo")
        return
    await update.message.reply_text(f"🔊 Echo: {text}")

async def time_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    stats["commands"] += 1
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    await update.message.reply_text(f"🕐 Current time: {now}")

async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    stats["commands"] += 1
    text = (
        "📊 Statistics:\n"
        f"  Total messages: {stats['messages']}\n"
        f"  Commands used: {stats['commands']}"
    )
    await update.message.reply_text(text)

async def about_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "🤖 Telegram Echo Bot\n"
        "Built with python-telegram-bot\n"
        "Source: github.com/your-repo\n"
        "MIT License"
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    stats["messages"] += 1
    text = update.message.text
    if text:
        await update.message.reply_text(f"🔊 You said: {text}")
    else:
        await update.message.reply_text("I only understand text messages.")

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    data = query.data
    if data == "help":
        await help_command(update, context)
    elif data == "time":
        await time_command(update, context)
    elif data == "stats":
        await stats_command(update, context)

def main():
    app = Application.builder().token(TOKEN).build()

    # Command handlers
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_command))
    app.add_handler(CommandHandler("echo", echo))
    app.add_handler(CommandHandler("time", time_command))
    app.add_handler(CommandHandler("stats", stats_command))
    app.add_handler(CommandHandler("about", about_command))

    # Message handler
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    # Callback query handler for inline keyboard
    app.add_handler(CallbackQueryHandler(button_callback))

    logger.info("Bot started. Press Ctrl+C to stop.")
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
