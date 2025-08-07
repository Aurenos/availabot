import birl
import datetime_utils as dtu
import gleam/list

type FollowingWeekdayTestCase {
  FollowingWeekdayTestCase(
    initial_date: String,
    weekday: birl.Weekday,
    expected_date: String,
  )
}

pub fn get_following_weekday_test() {
  // TODO: fix these
  // Cases are based on Sunday, August 3rd 2025
  let test_cases = [
    FollowingWeekdayTestCase("2025-08-03", birl.Mon, "2025-08-04"),
    FollowingWeekdayTestCase("2025-08-03", birl.Tue, "2025-08-05"),
    FollowingWeekdayTestCase("2025-08-03", birl.Wed, "2025-08-06"),
    FollowingWeekdayTestCase("2025-08-03", birl.Thu, "2025-08-07"),
    FollowingWeekdayTestCase("2025-08-03", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-03", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-03", birl.Sun, "2025-08-10"),
  ]

  list.each(test_cases, fn(test_case) {
    let assert Ok(initial) = birl.from_naive(test_case.initial_date)
    let assert Ok(expected) = birl.from_naive(test_case.expected_date)
    let next_weekday = dtu.get_following_weekday(initial, test_case.weekday)
    let expected_day = birl.get_day(expected)
    assert birl.get_day(next_weekday) == expected_day
  })
}

pub fn parse_date_test() {
  let assert Ok(date) = dtu.parse_simple_iso8601("1-1")
  echo birl.get_day(date)
}
