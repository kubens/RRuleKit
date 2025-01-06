//
//  ByWeekdayFilter.swift
//  RRuleKit
//
//  Created by kubens.com on 05/01/2025.
//

import Foundation

/// A filter that matches specific weekdays, optionally considering ordinal positions within a month.
///
/// The `ByWeekdayFilter` checks if a given date matches any of the specified weekdays.
/// It can also consider ordinal positions (e.g., the first Monday or the last Friday of a month)
/// based on the configuration.
///
/// This filter is commonly used in the context of recurrence rules, allowing fine-grained
/// control over which dates should match specific weekday and ordinal patterns.
public struct ByWeekdayFilter: Filter {

  /// The days of the week to match against, optionally including ordinal values.
  ///
  /// Each `DayOfWeek` specifies a day (e.g., Monday, Tuesday) and may include an ordinal
  /// (e.g., the first or last occurrence of the day in a month).
  public let daysOfTheWeek: [RecurrenceRule.DayOfWeek]

  /// Indicates whether ordinal matching should be used.
  ///
  /// If `true`, the ordinal values of the specified weekdays are considered when matching dates.
  /// If `false`, only the day of the week is checked, ignoring ordinal values.
  ///
  /// - Default: `true`
  public let useOrdinal: Bool

  /// Creates a new `ByWeekdayFilter` with the specified weekdays and ordinal matching behavior.
  ///
  /// - Parameters:
  ///   - daysOfTheWeek: An array of `DayOfWeek` to match against.
  ///   - useOrdinal: Whether to consider ordinal positions in the matching process. Defaults to `true`.
  public init(daysOfTheWeek: [RecurrenceRule.DayOfWeek], useOrdinal: Bool = true) {
    self.daysOfTheWeek = daysOfTheWeek
    self.useOrdinal = useOrdinal
  }

  /// Determines whether a given date matches the filter's criteria.
  ///
  /// The method checks if the date falls on one of the specified weekdays and optionally matches
  /// the ordinal position of the weekday within the month.
  ///
  /// - Parameters:
  ///   - date: The `Date` to evaluate.
  ///   - calendar: The `Calendar` to use for date calculations.
  /// - Returns: `true` if the date matches the filter's criteria; otherwise, `false`.
  public func matches(date: Date, in calendar: Calendar) -> Bool {
    guard let weekday = RecurrenceRule.Weekday(date, in: calendar) else { return false }
    let weekOfMonth = calendar.component(.weekOfMonth, from: date)
    let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: date)?.count ?? 0
    let reversedWeekOfMonth = -1 * (weeksInMonth - weekOfMonth + 1)

    for dayOfWeek in daysOfTheWeek {
      if dayOfWeek.weekday == weekday {
        if let ordinal = dayOfWeek.ordinal, useOrdinal {
          if ordinal > 0, ordinal == weekOfMonth { return true }
          if ordinal < 0, ordinal == reversedWeekOfMonth { return true }
        } else {
          return true
        }
      }
    }

    return false
  }
}
