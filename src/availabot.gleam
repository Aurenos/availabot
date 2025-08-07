import birl
import birl/duration
import date_utils
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
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import logging
import mkdn

type Command {
  ImOut(birl.Time)
  ImIn(birl.Time)
  ClearAbsences
}

type CommandParserError {
  InvalidCommand
  InvalidArgument(String)
}

type CommandHandlerError {
  CommandHandlerError(String)
}

type BotResponse {
  BotResponse(text: String, channel_id: String)
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

fn discord_event_handler(bot: bot.Bot, packet: event_handler.Packet) -> Nil {
  let msg_response = {
    use msg <- option.then(get_message(packet) |> option.from_result)
    logging.log(logging.Info, "Got message: " <> msg.d.content)

    case parse_command(msg.d.content) {
      Ok(cmd) -> {
        let output = case handle_command(cmd, msg.d.author) {
          Ok(out) -> out
          Error(CommandHandlerError(error_msg)) -> error_msg
        }

        Some(BotResponse(text: output, channel_id: msg.d.channel_id))
      }

      Error(InvalidArgument(error_msg)) -> {
        Some(BotResponse(text: error_msg, channel_id: msg.d.channel_id))
      }

      Error(InvalidCommand) -> None
    }
  }

  case msg_response {
    Some(response) -> send_bot_response(bot, response)
    None -> Nil
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

fn send_bot_response(bot: bot.Bot, response: BotResponse) -> Nil {
  let _ =
    discord_gleam.send_message(bot, response.channel_id, response.text, [])
  Nil
}

// CMD PARSERS ----------------------------------------------------------------

fn parse_command(msg_content: String) -> Result(Command, CommandParserError) {
  use <- bool.guard(
    when: !string.starts_with(msg_content, "!"),
    return: Error(InvalidCommand),
  )
  let cmd = string.drop_start(msg_content, up_to: 1)

  case cmd {
    "imout " <> args -> parse_availability_change(args, False)
    "imin " <> args -> parse_availability_change(args, True)
    _ -> Error(InvalidCommand)
  }
}

fn parse_availability_change(
  args: String,
  available: Bool,
) -> Result(Command, CommandParserError) {
  let arg = args |> string.trim |> string.lowercase
  let now = birl.utc_now()
  let current_year = birl.get_day(now).year
  let parse_res: Result(birl.Time, CommandParserError) = case
    arg,
    birl.parse_weekday(arg),
    date_utils.parse_simple_iso8601(arg, current_year)
  {
    "tomorrow", _, _ -> Ok(now |> birl.add(duration.days(1)))

    "today", _, _ | "tonight", _, _ -> Ok(now)

    _, Ok(weekday), _ -> Ok(date_utils.get_following_weekday(now, weekday))

    _, _, Ok(date) -> Ok(date)

    _, _, Error(date_utils.InvalidDateFormat(err_msg)) ->
      Error(InvalidArgument(err_msg))
  }

  result.map(parse_res, fn(parsed_time) {
    case available {
      True -> ImIn(parsed_time)
      False -> ImOut(parsed_time)
    }
  })
}

// CMD HANDLERS ----------------------------------------------------------------

fn handle_command(
  command: Command,
  user: user.User,
) -> Result(String, CommandHandlerError) {
  case command {
    ImOut(time) -> handle_imout(time, user)
    ImIn(time) -> handle_imin(time, user)
    ClearAbsences -> clear_absences(user)
  }
}

fn handle_imout(
  time: birl.Time,
  user: user.User,
) -> Result(String, CommandHandlerError) {
  // Todo: Actual data storage updates
  let current_day = date_utils.utc_now_midnight()
  case birl.to_unix(time) < birl.to_unix(current_day) {
    True -> Error(CommandHandlerError("That day has already passed."))
    _ ->
      Ok(
        mkdn.bold(user.username)
        <> " will be unavailable on "
        <> dt.to_discord_timestamp(time, dt.LongDate),
      )
  }
}

fn handle_imin(
  time: birl.Time,
  user: user.User,
) -> Result(String, CommandHandlerError) {
  // Todo: Actual data storage updates
  let current_day = date_utils.utc_now_midnight()
  case birl.to_unix(time) < birl.to_unix(current_day) {
    True -> Error(CommandHandlerError("That day has already passed."))
    _ ->
      Ok(
        mkdn.bold(user.username)
        <> " is available on "
        <> dt.to_discord_timestamp(time, dt.LongDate),
      )
  }
}

fn clear_absences(user: user.User) -> Result(String, CommandHandlerError) {
  todo
}
