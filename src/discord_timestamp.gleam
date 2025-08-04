import birl
import gleam/int

pub type TimestampFormat {
  ShortTime
  LongTime
  ShortDate
  LongDate
  ShortDateTime
  LongDateTime
  Relative
}

fn timestamp_format(format: TimestampFormat) -> String {
  case format {
    ShortTime -> ":t"
    LongTime -> ":T"
    ShortDate -> ":d"
    LongDate -> ":D"
    ShortDateTime -> ""
    LongDateTime -> ":F"
    Relative -> ":R"
  }
}

pub fn to_discord_timestamp(time: birl.Time, format: TimestampFormat) -> String {
  let unix_str =
    time
    |> birl.to_unix()
    |> int.to_string()
  "<t:" <> unix_str <> timestamp_format(format) <> ">"
}
