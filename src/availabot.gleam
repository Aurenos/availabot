import birl
import birl/duration
import datetime_utils
import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/bot
import discord_gleam/types/user
import discord_gleam/ws/packets/message
import discord_timestamp as dt
import dotenv_gleam
import envoy
import gleam/bool
import gleam/order
import gleam/result
import gleam/string
import logging
import mkdn

type Command {
  ImOut(birl.Time)
}

type CommandOutput =
  Result(String, String)

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
  discord_gleam.run(bot, [discord_event_handler])
}

fn discord_event_handler(bot: bot.Bot, packet: event_handler.Packet) {
  case get_message(packet) {
    Ok(msg) -> {
      logging.log(logging.Info, "Got message: " <> msg.d.content)

      case parse_command(msg.d.content) {
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

fn get_message(
  packet: event_handler.Packet,
) -> Result(message.MessagePacket, Nil) {
  case packet {
    event_handler.MessagePacket(msg_packet) -> Ok(msg_packet)
    _ -> Error(Nil)
  }
}

// CMD PARSERS ----------------------------------------------------------------

fn parse_command(msg_content: String) -> Result(Command, String) {
  use <- bool.guard(
    when: !string.starts_with(msg_content, "!"),
    return: Error(""),
  )
  let cmd = string.drop_start(msg_content, up_to: 1)

  case cmd {
    "imout" <> args -> parse_imout(args)
    _ -> Error("")
  }
}

fn parse_imout(args: String) -> Result(Command, String) {
  let arg = args |> string.trim |> string.lowercase
  case arg, birl.parse_weekday(arg), datetime_utils.parse_simple_iso8601(arg) {
    "tomorrow", _, _ -> {
      let tomorrow = birl.utc_now() |> birl.add(duration.days(1))
      Ok(ImOut(tomorrow))
    }

    "today", _, _ -> Ok(ImOut(birl.utc_now()))

    _, Ok(weekday), _ -> {
      Ok(ImOut(datetime_utils.get_following_weekday(birl.utc_now(), weekday)))
    }

    _, _, simple_output -> {
      use date <- result.try(simple_output)

      // TODO: Does this actually belong in this function?
      case birl.compare(date, birl.utc_now()) {
        order.Lt -> Error("That day has already passed.")
        _ -> Ok(ImOut(date))
      }
    }
  }
}

// CMD HANDLERS ----------------------------------------------------------------

fn handle_command(command: Command, user: user.User) -> CommandOutput {
  case command {
    ImOut(time) -> handle_imout(time, user)
  }
}

fn handle_imout(time: birl.Time, user: user.User) -> CommandOutput {
  Ok(
    mkdn.bold(user.username)
    <> " will be unavailable on "
    <> dt.to_discord_timestamp(time, dt.LongDate),
  )
}
