🤖 Telegram Echo Bot – Multi‑Language Edition

A simple **Telegram echo bot** that replies to messages, supports basic commands, and demonstrates how to interact with the Telegram Bot API.  
Built in **7 programming languages** – perfect for learning bot development, API integration, or as a starting point for your own bots.

## ✨ Features
- **Echo** – repeats any message sent to the bot.
- **Commands** – `/start`, `/help`, `/echo <text>`, `/time`, `/stats`, `/about`.
- **Inline keyboard** – quick action buttons (optional).
- **Error handling** – graceful fallback for invalid inputs.
- **Statistics** – tracks total messages and command usage.
- **Easy to extend** – add your own commands with minimal effort.

## 🗂 Languages & Libraries
| Language          | Library / Framework               | File            |
|-------------------|-----------------------------------|-----------------|
| Python            | `python-telegram-bot`             | `bot.py`        |
| Go                | `telebot`                         | `bot.go`        |
| JavaScript (Node) | `node-telegram-bot-api`           | `bot.js`        |
| C#                | `Telegram.Bot`                    | `Bot.cs`        |
| Java              | `TelegramBots`                    | `Bot.java`      |
| Ruby              | `telegram-bot-ruby`               | `bot.rb`        |
| Swift             | `Vapor` / `TelegramBotSDK` (or URLSession) | `bot.swift` |

## 🚀 How to Run
Each file is standalone – you'll need a **Telegram Bot Token** from [@BotFather](https://t.me/botfather).

1. Clone or download the repository.
2. Install dependencies for your chosen language (see below).
3. Set your bot token as an environment variable `BOT_TOKEN` or replace it in the code.
4. Run the bot.

| Language | Install Dependencies | Run Command |
|----------|----------------------|-------------|
| Python   | `pip install python-telegram-bot` | `python bot.py` |
| Go       | `go get github.com/tucnak/telebot` | `go run bot.go` |
| JavaScript | `npm install node-telegram-bot-api` | `node bot.js` |
| C#       | `dotnet add package Telegram.Bot` | `dotnet run` |
| Java     | Add `telegrambots` dependency in `pom.xml` / Gradle | `java Bot` |
| Ruby     | `gem install telegram-bot-ruby` | `ruby bot.rb` |
| Swift    | Add `TelegramBotSDK` (or use URLSession) | `swift bot.swift` |

## 📊 Example Session
User: /start
Bot: Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.

User: /echo Hello, world!
Bot: Echo: Hello, world!

User: /time
Bot: 2026-07-11 14:32:45 UTC

User: /stats
Bot: 📊 Statistics:
Total messages: 42
Commands used: 15

text

## 🔧 Commands
| Command | Description |
|---------|-------------|
| `/start` | Welcome message |
| `/help` | List available commands |
| `/echo <text>` | Echo back the given text |
| `/time` | Show current server time (UTC) |
| `/stats` | Show usage statistics |
| `/about` | About this bot |

## 🔒 Environment Variables
- `BOT_TOKEN` – your Telegram bot token (required).

## 🤝 Contributing
Add more commands, inline keyboards, or database integration – PRs welcome!

## 📜 License
MIT – use freely.
