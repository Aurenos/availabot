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
import gleam/string
import logging
import mkdn

type Command {
  ImOut(birl.Time)
}

type CommandParserError {
  InvalidCommand
  InvalidArgument(String)
}

type CommandHandlerError {
  CommandHandlerError(String)
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
  discord_gleam.run(bot, [discord_event_handler])
}

fn discord_event_handler(bot: bot.Bot, packet: event_handler.Packet) {
  case get_message(packet) {
    Ok(msg) -> {
      logging.log(logging.Info, "Got message: " <> msg.d.content)

      case parse_command(msg.d.content) {
        Ok(cmd) -> {
          let output = case handle_command(cmd, msg.d.author) {
            Ok(out) -> out
            Error(CommandHandlerError(error_msg)) -> error_msg
          }

          let _ = discord_gleam.send_message(bot, msg.d.channel_id, output, [])
          Nil
        }

        Error(InvalidCommand) -> Nil

        Error(InvalidArgument(error_msg)) -> {
          let _ =
            discord_gleam.send_message(bot, msg.d.channel_id, error_msg, [])
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

fn parse_command(msg_content: String) -> Result(Command, CommandParserError) {
  use <- bool.guard(
    when: !string.starts_with(msg_content, "!"),
    return: Error(InvalidCommand),
  )
  let cmd = string.drop_start(msg_content, up_to: 1)

  case cmd {
    "imout" <> args -> parse_imout(args)
    _ -> Error(InvalidCommand)
  }
}

fn parse_imout(args: String) -> Result(Command, CommandParserError) {
  let arg = args |> string.trim |> string.lowercase
  case arg, birl.parse_weekday(arg), datetime_utils.parse_simple_iso8601(arg) {
    "tomorrow", _, _ -> {
      let tomorrow = birl.utc_now() |> birl.add(duration.days(1))
      Ok(ImOut(tomorrow))
    }

    "today", _, _ | "tonight", _, _ -> Ok(ImOut(birl.utc_now()))

    _, Ok(weekday), _ -> {
      Ok(ImOut(datetime_utils.get_following_weekday(birl.utc_now(), weekday)))
    }

    _, _, Ok(date) -> Ok(ImOut(date))

    _, _, Error(err) -> Error(InvalidArgument(err))
  }
}

// CMD HANDLERS ----------------------------------------------------------------

fn handle_command(
  command: Command,
  user: user.User,
) -> Result(String, CommandHandlerError) {
  case command {
    ImOut(time) -> handle_imout(time, user)
  }
}

fn handle_imout(
  time: birl.Time,
  user: user.User,
) -> Result(String, CommandHandlerError) {
  case birl.compare(time, birl.utc_now()) {
    order.Lt -> Error(CommandHandlerError("That day has already passed."))
    _ ->
      Ok(
        mkdn.bold(user.username)
        <> " will be unavailable on "
        <> dt.to_discord_timestamp(time, dt.LongDate),
      )
  }
}
