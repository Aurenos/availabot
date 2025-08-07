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
    let next_weekday = dtu.get_following_weekday(initial, test_case.weekday)
    let expected_day = birl.get_day(expected)
    assert birl.get_day(next_weekday) == expected_day
  })
}
