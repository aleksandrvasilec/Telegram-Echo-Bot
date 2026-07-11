// bot.go
package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	tele "gopkg.in/telebot.v3"
)

var stats = struct {
	Messages int
	Commands int
}{}

func main() {
	token := os.Getenv("BOT_TOKEN")
	if token == "" {
		log.Fatal("BOT_TOKEN environment variable not set")
	}

	pref := tele.Settings{
		Token:  token,
		Poller: &tele.LongPoller{Timeout: 10 * time.Second},
	}

	b, err := tele.NewBot(pref)
	if err != nil {
		log.Fatal(err)
	}

	// Command: /start
	b.Handle("/start", func(c tele.Context) error {
		return c.Send("Hello! I'm an Echo Bot. Send me anything and I'll echo it back. Use /help for commands.")
	})

	// Command: /help
	b.Handle("/help", func(c tele.Context) error {
		text := "Available commands:\n" +
			"/start - Welcome message\n" +
			"/help - Show this help\n" +
			"/echo <text> - Echo back your text\n" +
			"/time - Show current server time\n" +
			"/stats - Show usage statistics\n" +
			"/about - About this bot"
		return c.Send(text)
	})

	// Command: /echo
	b.Handle("/echo", func(c tele.Context) error {
		stats.Messages++
		text := strings.TrimSpace(c.Message().Payload)
		if text == "" {
			return c.Send("Please provide text after /echo")
		}
		return c.Send(fmt.Sprintf("🔊 Echo: %s", text))
	})

	// Command: /time
	b.Handle("/time", func(c tele.Context) error {
		stats.Commands++
		now := time.Now().UTC().Format("2006-01-02 15:04:05 UTC")
		return c.Send(fmt.Sprintf("🕐 Current time: %s", now))
	})

	// Command: /stats
	b.Handle("/stats", func(c tele.Context) error {
		stats.Commands++
		text := fmt.Sprintf("📊 Statistics:\n  Total messages: %d\n  Commands used: %d",
			stats.Messages, stats.Commands)
		return c.Send(text)
	})

	// Command: /about
	b.Handle("/about", func(c tele.Context) error {
		return c.Send("🤖 Telegram Echo Bot\nBuilt with telebot\nMIT License")
	})

	// Handle text messages
	b.Handle(tele.OnText, func(c tele.Context) error {
		stats.Messages++
		text := c.Message().Text
		if strings.HasPrefix(text, "/") {
			// Already handled by command handlers
			return nil
		}
		return c.Send(fmt.Sprintf("🔊 You said: %s", text))
	})

	log.Println("Bot started. Press Ctrl+C to stop.")
	b.Start()
}
