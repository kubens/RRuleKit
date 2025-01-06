//
//  RecurrenceRule+Weekday.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

import Foundation

extension RecurrenceRule {

  /// Represents the days of the week for a recurrence rule.
  ///
  /// Each case corresponds to a day of the week, represented by:
  /// - Its standard two-letter abbreviation as used in iCalendar (RFC 5545) rules.
  /// - An integer value (Sunday = 1, Monday = 2, ..., Saturday = 7), consistent with the `Calendar`
  ///   component `.weekday` in Foundation.
  public enum Weekday: String, RawRepresentable, Sendable {

    /// Represents Monday.
    case monday = "MO"

    /// Represents Tuesday.
    case tuesday = "TU"

    /// Represents Wednesday.
    case wednesday = "WE"

    /// Represents Thursday.
    case thursday = "TH"

    /// Represents Friday.
    case friday = "FR"

    /// Represents Saturday.
    case saturday = "SA"

    /// Represents Sunday.
    case sunday = "SU"

    /// The integer value of the day of the week, consistent with Foundation's `Calendar` component `.weekday`.
    ///
    /// This maps the day to its numeric representation as used by `Calendar`:
    /// - `1` for Sunday
    /// - `2` for Monday
    /// - `3` for Tuesday
    /// - `4` for Wednesday
    /// - `5` for Thursday
    /// - `6` for Friday
    /// - `7` for Saturday
    ///
    /// This value aligns with how `Calendar` interprets weekdays in its `.weekday` component.
    public var intValue: Int {
      switch self {
      case .sunday:     1
      case .monday:     2
      case .tuesday:    3
      case .wednesday:  4
      case .thursday:   5
      case .friday:     6
      case .saturday:   7
      }
    }

    /// Initializes a `Weekday` from its raw string value.
    ///
    /// - Parameter rawValue: The two-letter abbreviation for the day of the week (e.g., `"MO"`, `"TU"`).
    public init?(_ rawValue: String) {
      self.init(rawValue: rawValue)
    }

    /// Initializes a `Weekday` from a substring representation of its raw value.
    ///
    /// - Parameter rawValue: A substring representation of the two-letter abbreviation for the day of the week.
    public init?(_ rawValue: Substring) {
      self.init(rawValue: String(rawValue))
    }

    /// Initializes a `Weekday` from its integer value, consistent with Foundation's `Calendar`.
    ///
    /// This maps the integer values `1` through `7` to their corresponding weekdays:
    /// - `1` for Sunday
    /// - `2` for Monday
    /// - `3` for Tuesday
    /// - `4` for Wednesday
    /// - `5` for Thursday
    /// - `6` for Friday
    /// - `7` for Saturday
    ///
    /// These values align with how `Calendar` interprets weekdays in its `.weekday` component.
    ///
    /// - Parameter intValue: The integer value of the weekday.
    public init?(_ intValue: Int) {
      switch intValue {
      case 1: self = .sunday
      case 2: self = .monday
      case 3: self = .tuesday
      case 4: self = .wednesday
      case 5: self = .thursday
      case 6: self = .friday
      case 7: self = .saturday
      default: return nil
      }
    }

    /// Initializes a `Weekday` from a `Date` using the specified `Calendar`.
    ///
    /// This initializer uses the `.weekday` component of the provided `Calendar`
    /// to determine the corresponding `Weekday`.
    ///
    /// - Parameters:
    ///   - date: The `Date` to convert to a `Weekday`.
    ///   - calendar: The `Calendar` to use for determining the weekday. Defaults to `.current`.
    ///
    /// Example:
    /// ```swift
    /// let today = Date()
    /// if let weekday = RecurrenceRule.Weekday(today) {
    ///     print("Today is \(weekday)")
    /// }
    /// ```
    public init?(_ date: Date, in calendar: Calendar = .current) {
      let weekdayByCalendar = calendar.component(.weekday, from: date)
      self.init(weekdayByCalendar)
    }
  }
}
