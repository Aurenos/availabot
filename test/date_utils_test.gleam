import birl
import date_utils
import gleam/list
import gleam/option.{type Option, None, Some}

type FollowingWeekdayTestCase {
  FollowingWeekdayTestCase(
    initial_date: String,
    weekday: birl.Weekday,
    expected_date: String,
  )
}

type ParseSimpleISO8601TestCase {
  ParseSimpleISO8601TestCase(
    text: String,
    expected: Option(birl.Day),
    year: Int,
  )
}

pub fn get_following_weekday_test() {
  // Cases are based on Sunday, August 3rd 2025
  let test_cases_sun = [
    FollowingWeekdayTestCase("2025-08-03", birl.Mon, "2025-08-04"),
    FollowingWeekdayTestCase("2025-08-03", birl.Tue, "2025-08-05"),
    FollowingWeekdayTestCase("2025-08-03", birl.Wed, "2025-08-06"),
    FollowingWeekdayTestCase("2025-08-03", birl.Thu, "2025-08-07"),
    FollowingWeekdayTestCase("2025-08-03", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-03", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-03", birl.Sun, "2025-08-10"),
  ]

  let test_cases_mon = [
    FollowingWeekdayTestCase("2025-08-04", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-04", birl.Tue, "2025-08-05"),
    FollowingWeekdayTestCase("2025-08-04", birl.Wed, "2025-08-06"),
    FollowingWeekdayTestCase("2025-08-04", birl.Thu, "2025-08-07"),
    FollowingWeekdayTestCase("2025-08-04", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-04", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-04", birl.Sun, "2025-08-10"),
  ]

  let test_cases_tue = [
    FollowingWeekdayTestCase("2025-08-05", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-05", birl.Tue, "2025-08-12"),
    FollowingWeekdayTestCase("2025-08-05", birl.Wed, "2025-08-06"),
    FollowingWeekdayTestCase("2025-08-05", birl.Thu, "2025-08-07"),
    FollowingWeekdayTestCase("2025-08-05", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-05", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-05", birl.Sun, "2025-08-10"),
  ]

  let test_cases_wed = [
    FollowingWeekdayTestCase("2025-08-06", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-06", birl.Tue, "2025-08-12"),
    FollowingWeekdayTestCase("2025-08-06", birl.Wed, "2025-08-13"),
    FollowingWeekdayTestCase("2025-08-06", birl.Thu, "2025-08-07"),
    FollowingWeekdayTestCase("2025-08-06", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-06", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-06", birl.Sun, "2025-08-10"),
  ]

  let test_cases_thu = [
    FollowingWeekdayTestCase("2025-08-07", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-07", birl.Tue, "2025-08-12"),
    FollowingWeekdayTestCase("2025-08-07", birl.Wed, "2025-08-13"),
    FollowingWeekdayTestCase("2025-08-07", birl.Thu, "2025-08-14"),
    FollowingWeekdayTestCase("2025-08-07", birl.Fri, "2025-08-08"),
    FollowingWeekdayTestCase("2025-08-07", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-07", birl.Sun, "2025-08-10"),
  ]

  let test_cases_fri = [
    FollowingWeekdayTestCase("2025-08-08", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-08", birl.Tue, "2025-08-12"),
    FollowingWeekdayTestCase("2025-08-08", birl.Wed, "2025-08-13"),
    FollowingWeekdayTestCase("2025-08-08", birl.Thu, "2025-08-14"),
    FollowingWeekdayTestCase("2025-08-08", birl.Fri, "2025-08-15"),
    FollowingWeekdayTestCase("2025-08-08", birl.Sat, "2025-08-09"),
    FollowingWeekdayTestCase("2025-08-08", birl.Sun, "2025-08-10"),
  ]

  let test_cases_sat = [
    FollowingWeekdayTestCase("2025-08-09", birl.Mon, "2025-08-11"),
    FollowingWeekdayTestCase("2025-08-09", birl.Tue, "2025-08-12"),
    FollowingWeekdayTestCase("2025-08-09", birl.Wed, "2025-08-13"),
    FollowingWeekdayTestCase("2025-08-09", birl.Thu, "2025-08-14"),
    FollowingWeekdayTestCase("2025-08-09", birl.Fri, "2025-08-15"),
    FollowingWeekdayTestCase("2025-08-09", birl.Sat, "2025-08-16"),
    FollowingWeekdayTestCase("2025-08-09", birl.Sun, "2025-08-10"),
  ]

  [
    test_cases_sun,
    test_cases_mon,
    test_cases_tue,
    test_cases_wed,
    test_cases_thu,
    test_cases_fri,
    test_cases_sat,
  ]
  |> list.flatten
  |> list.each(fn(test_case) {
    let assert Ok(initial) = birl.from_naive(test_case.initial_date)
    let assert Ok(expected) = birl.from_naive(test_case.expected_date)
    let next_weekday =
      date_utils.get_following_weekday(initial, test_case.weekday)
    let expected_day = birl.get_day(expected)
    assert birl.get_day(next_weekday) == expected_day
  })
}

pub fn parse_simple_iso8601_test() {
  let test_cases = [
    ParseSimpleISO8601TestCase("2025-01-01", Some(birl.Day(2025, 1, 1)), 2025),
    ParseSimpleISO8601TestCase("01-01", Some(birl.Day(2025, 1, 1)), 2025),
    ParseSimpleISO8601TestCase("1-1", Some(birl.Day(2025, 1, 1)), 2025),
    ParseSimpleISO8601TestCase("10-1", Some(birl.Day(2026, 10, 1)), 2026),
    ParseSimpleISO8601TestCase("10-10", Some(birl.Day(2026, 10, 10)), 2026),
    ParseSimpleISO8601TestCase("bad", None, 2026),
  ]

  test_cases
  |> list.each(fn(test_case) {
    let parse_res =
      date_utils.parse_simple_iso8601(test_case.text, test_case.year)
    case test_case.expected {
      Some(expected_day) -> {
        let assert Ok(time) = parse_res
        assert birl.get_day(time) == expected_day
      }
      None -> {
        let assert Error(err) = parse_res
        assert err
          == date_utils.InvalidDateFormat(
            "Invalid date format. Expected either YYYY-MM-DD or MM-DD",
          )
      }
    }
  })
}
