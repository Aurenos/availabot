import birl
import birl/duration
import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/bot
import discord_gleam/types/user
import dotenv_gleam
import envoy
import gleam/bool
import gleam/int
import gleam/result
import gleam/string
import logging

type Command {
  Ping
  ImOut(birl.Time)
}

pub fn main() {
  let assert Ok(Nil) = dotenv_gleam.config()
  let assert Ok(client_id) = envoy.get("DISCORD_CLIENT_ID")
  let assert Ok(discord_token) = envoy.get("DISCORD_TOKEN")

  logging.configure()
  logging.set_level(logging.Info)

  let bot =
    discord_gleam.bot(
      discord_token,
      client_id,
      intents.default_with_message_intents(),
    )

  logging.log(logging.Info, "Starting Availabot")
  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot: bot.Bot, packet: event_handler.Packet) {
  case packet {
    event_handler.MessagePacket(msg) -> {
      logging.log(logging.Info, "Got message: " <> msg.d.content)
      echo case parse_command(msg.d.content) {
        Ok(cmd) -> {
          let output =
            cmd |> handle_command(msg.d.author) |> result.unwrap_both()
          let _ = discord_gleam.send_message(bot, msg.d.channel_id, output, [])
          Nil
        }
        Error("") -> Nil
        Error(err) -> {
          let _ = discord_gleam.send_message(bot, msg.d.channel_id, err, [])
          Nil
        }
      }
    }
    _ -> Nil
  }
}

fn parse_command(msg_content: String) -> Result(Command, String) {
  use <- bool.guard(
    when: !string.starts_with(msg_content, "!"),
    return: Error(""),
  )
  let cmd = string.drop_start(msg_content, up_to: 1)

  case cmd {
    "ping" <> _ -> Ok(Ping)
    "imout" <> args -> parse_imout(args)
    _ -> Error("")
  }
}

fn parse_imout(args: String) -> Result(Command, String) {
  case string.trim(args) {
    "tomorrow" -> {
      let tomorrow = birl.now() |> birl.add(duration.days(1))
      Ok(ImOut(tomorrow))
    }
    _ -> Error("I don't understand")
  }
}

fn handle_command(command: Command, user: user.User) -> Result(String, String) {
  case command {
    Ping -> Ok("Pong!")
    ImOut(time) -> {
      let unix_time = time |> birl.to_unix() |> int.to_string()
      let discord_timestamp = "<t:" <> unix_time <> ":d>"
      Ok("**" <> user.username <> "** " <> " is out " <> discord_timestamp)
    }
  }
}
