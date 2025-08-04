import birl
import birl/duration
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

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

const invalid_date_format_msg = "Invalid date format. Expected either YYYY-MM-DD or MM-DD"

fn days_until_following_weekday(
  from: birl.Time,
  weekday: birl.Weekday,
) -> duration.Duration {
  let from_weekday = birl.weekday(from)
  let day_cycle =
    weekday_list
    |> yielder.from_list
    |> yielder.cycle
  // Cycle to the current weekday first
  let _ = day_cycle |> yielder.take_while(fn(day) { day != from_weekday })

  day_cycle
  |> yielder.fold_until(0, fn(n, wday) {
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

pub fn parse_simple_iso8601(input: String) -> Result(birl.Time, String) {
  // There's probably a better way of doing this than the weird concat, but it gets the job done for now?
  use _ <- result.try_recover(birl.parse(input <> " " <> midnight_utc))
  case string.split(input, "-") {
    [month, day] -> {
      let current_day = birl.utc_now() |> birl.get_day()
      let date_str =
        current_day.year
        |> int.to_string()
        |> list.prepend([month, day], _)
        |> string.join("-")

      birl.parse(date_str <> " " <> midnight_utc)
      |> result.replace_error(invalid_date_format_msg)
    }
    _ -> Error(invalid_date_format_msg)
  }
}
