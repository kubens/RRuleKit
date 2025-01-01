//
//  RecurrenceRule+DayOfWeek.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

import Foundation

extension RecurrenceRule {

  /// Represents a day of the week with an optional ordinal modifier.
  ///
  /// For example:
  /// - `DayOfWeek.every(.monday)` represents every Monday.
  /// - `DayOfWeek.first(.monday)` represents the first Monday of the interval.
  /// - `DayOfWeek.last(.monday)` represents the last Monday of the interval.
  /// - `DayOfWeek.nth(2, .monday)` represents the second Monday of the interval.
  public struct DayOfWeek: Equatable, Sendable {

    /// Creates a `DayOfWeek` representing every occurrence of the specified weekday.
    ///
    /// - Parameter weekday: The weekday to be included in the recurrence.
    /// - Returns: A `DayOfWeek` instance.
    public static func every(weekday: RecurrenceRule.Weekday) -> DayOfWeek {
      RecurrenceRule.DayOfWeek(ordinal: nil, weekday: weekday)
    }

    /// Creates a `DayOfWeek` representing the first occurrence of the specified weekday in the interval.
    ///
    /// - Parameter weekday: The weekday to be included in the recurrence.
    /// - Returns: A `DayOfWeek` instance.
    public static func first(weekday: RecurrenceRule.Weekday) -> DayOfWeek {
      RecurrenceRule.DayOfWeek(ordinal: 1, weekday: weekday)
    }

    /// Creates a `DayOfWeek` representing the last occurrence of the specified weekday in the interval.
    ///
    /// - Parameter weekday: The weekday to be included in the recurrence.
    /// - Returns: A `DayOfWeek` instance.
    public static func last(weekday: RecurrenceRule.Weekday) -> DayOfWeek {
      RecurrenceRule.DayOfWeek(ordinal: -1, weekday: weekday)
    }

    /// Creates a `DayOfWeek` representing the nth occurrence of the specified weekday in the interval.
    ///
    /// - Parameters:
    ///   - ordinal: The nth occurrence (e.g., `1` for the first, `-1` for the last).
    ///   - weekday: The weekday to be included in the recurrence.
    /// - Returns: A `DayOfWeek` instance.
    public static func nth(_ ordinal: Int, weekday: RecurrenceRule.Weekday) -> DayOfWeek {
      RecurrenceRule.DayOfWeek(ordinal: ordinal, weekday: weekday)
    }

    /// The ordinal modifier indicating which occurrence of the weekday to include.
    ///
    /// For example:
    /// - `1` for the first occurrence.
    /// - `-1` for the last occurrence.
    /// - `nil` if every occurrence is included.
    public var ordinal: Int?

    /// The day of the week being represented.
    public var weekday: RecurrenceRule.Weekday

    /// Creates a new `DayOfWeek` with the specified ordinal and weekday.
    ///
    /// - Parameters:
    ///   - ordinal: The ordinal modifier (or `nil` for every occurrence).
    ///   - weekday: The day of the week to include in the recurrence.
    private init(ordinal: Int? = nil, weekday: RecurrenceRule.Weekday) {
      self.ordinal = ordinal
      self.weekday = weekday
    }
  }
}

// MARK: - RawRepresentable
extension RecurrenceRule.DayOfWeek: RawRepresentable {

  /// A string representation of the `DayOfWeek` in iCalendar format.
  ///
  /// For example:
  /// - `"MO"` for every Monday.
  /// - `"1MO"` for the first Monday.
  /// - `"-1MO"` for the last Monday.
  public var rawValue: String {
    guard let ordinal else { return weekday.rawValue }
    return "\(ordinal)\(weekday)"
  }

  /// Creates a `DayOfWeek` from its iCalendar string representation.
  ///
  /// - Parameter rawValue: A string in iCalendar format (e.g., `"MO"`, `"1MO"`, `"-1MO"`).
  public init?(rawValue: String) {
    let pattern = #"^((?:-?[1-5])?)([A-Z]{2})$"#
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(rawValue.startIndex..<rawValue.endIndex, in: rawValue)
    guard let regex, let match = regex.firstMatch(in: rawValue, range: range) else { return nil }

    if
      let range = Range(match.range(at: 2), in: rawValue),
      let weekday = RecurrenceRule.Weekday(rawValue[range])
    {
      self.weekday = weekday
    } else {
      return nil
    }

    if
      let range = Range(match.range(at: 1), in: rawValue),
      let ordinal = Int(rawValue[range])
    {
      self.ordinal = ordinal
    }
  }

  /// Convenience initializer for `DayOfWeek` from a string.
  ///
  /// - Parameter rawValue: A string in iCalendar format.
  public init?(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }

  /// Convenience initializer for `DayOfWeek` from a substring.
  ///
  /// - Parameter rawValue: A substring in iCalendar format.
  public init?(_ rawValue: Substring) {
    self.init(rawValue: String(rawValue))
  }
}
