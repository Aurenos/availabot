import birl
import birl/duration
import gleam/list
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

fn next_weekday_days(
  from: birl.Time,
  weekday: birl.Weekday,
) -> duration.Duration {
  let from_weekday = birl.weekday(from)
  let day_cycle =
    weekday_list
    |> yielder.from_list
    |> yielder.cycle
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

pub fn get_next_weekday(weekday: birl.Weekday) -> birl.Time {
  let now = birl.now()
  let duration = next_weekday_days(now, weekday)
  birl.add(now, duration)
}
