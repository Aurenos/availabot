import birl
import birl/duration
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type DateParseError {
  InvalidDateFormat
}

const weekday_list = [
  birl.Mon,
  birl.Tue,
  birl.Wed,
  birl.Thu,
  birl.Fri,
  birl.Sat,
  birl.Sun,
]

const midnight_utc = "23:59:59-0"

pub const invalid_date_format_msg = "Invalid date format. Expected either YYYY-MM-DD or MM-DD"

fn days_until_following_weekday(
  from: birl.Time,
  weekday: birl.Weekday,
) -> duration.Duration {
  let from_weekday = birl.weekday(from)
  use <- bool.guard(when: weekday == from_weekday, return: duration.days(7))

  let #(weekdays_to_current, weekdays_after_current) =
    weekday_list |> list.split_while(fn(wday) { wday != from_weekday })

  weekdays_after_current
  |> list.filter(fn(wday) { wday != from_weekday })
  |> list.append(weekdays_to_current)
  |> list.fold_until(0, fn(n, wday) {
    case wday == weekday {
      True -> list.Stop(n + 1)
      False -> list.Continue(n + 1)
    }
  })
  |> duration.days()
}

pub fn get_following_weekday(
  from: birl.Time,
  weekday: birl.Weekday,
) -> birl.Time {
  let duration = days_until_following_weekday(from, weekday)
  birl.add(from, duration)
}

pub fn parse_simple_iso8601(
  input: String,
  year: Int,
) -> Result(birl.Time, DateParseError) {
  // There's probably a better way of doing this than the weird concat, but it gets the job done for now?
  use _ <- result.try_recover(birl.parse(input <> " " <> midnight_utc))
  case string.split(input, "-") {
    [month, day] -> {
      let date_str =
        year
        |> int.to_string()
        |> list.prepend([month, day], _)
        |> string.join("-")

      birl.parse(date_str <> " " <> midnight_utc)
      |> result.replace_error(InvalidDateFormat)
    }
    _ -> Error(InvalidDateFormat)
  }
}
