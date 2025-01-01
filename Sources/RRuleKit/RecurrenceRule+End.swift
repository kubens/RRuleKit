//
//  RecurrenceRule+End.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

import Foundation

extension RecurrenceRule {

  /// Specifies when a recurring event should stop recurring.
  ///
  /// An `End` instance can define the recurrence's termination in one of three ways:
  /// - Repeating indefinitely (`.never`).
  /// - Ending after a specific number of occurrences (`.afterOccurrences`).
  /// - Ending on a specific date (`.afterDate`).
  public struct End: Equatable, Sendable {

    /// Represents an event that repeats indefinitely.
    ///
    /// Example:
    /// ```swift
    /// let end = RecurrenceRule.End.never
    /// ```
    public static var never: RecurrenceRule.End {
      RecurrenceRule.End()
    }

    /// Creates an `End` instance that stops the recurrence after a specified number of occurrences.
    ///
    /// - Parameter count: The number of times the event should occur before stopping.
    /// - Returns: An `End` instance.
    ///
    /// Example:
    /// ```swift
    /// let end = RecurrenceRule.End.afterOccurrences(10) // Stops after 10 occurrences.
    /// ```
    public static func afterOccurrences(_ count: Int) -> RecurrenceRule.End {
      RecurrenceRule.End(occurrences: count)
    }

    /// Creates an `End` instance that stops the recurrence after a specified date.
    ///
    /// - Parameter date: The date after which the event should no longer occur.
    /// - Returns: An `End` instance.
    ///
    /// Example:
    /// ```swift
    /// let end = RecurrenceRule.End.afterDate(Date()) // Stops after the current date.
    /// ```
    public static func afterDate(_ date: Date) -> RecurrenceRule.End {
      RecurrenceRule.End(date: date)
    }

    /// Creates an `End` instance from a raw string representing the number of occurrences.
    ///
    /// - Parameter rawCount: A string representation of the number of occurrences.
    /// - Returns: An optional `End` instance if the string is a valid number.
    public static func afterOccurrences(_ rawCount: String) -> RecurrenceRule.End? {
      guard let count = Int(rawCount) else { return nil }
      return .afterOccurrences(count)
    }

    /// Creates an `End` instance from a raw substring representing the number of occurrences.
    ///
    /// - Parameter rawCount: A substring representation of the number of occurrences.
    /// - Returns: An optional `End` instance if the substring is a valid number.
    public static func afterOccurrences(_ rawCount: Substring) -> RecurrenceRule.End? {
      return .afterOccurrences(String(rawCount))
    }

    /// Creates an `End` instance from a raw string representing a date.
    ///
    /// - Parameter rawDate: A string representation of the date in ISO 8601 format.
    /// - Returns: An optional `End` instance if the string is a valid date.
    public static func afterDate(_ rawDate: String) -> RecurrenceRule.End? {
      let isoFormatter = ISO8601DateFormatter()
      guard let date = isoFormatter.date(from: rawDate) else { return nil }
      return .afterDate(date)
    }

    /// Creates an `End` instance from a raw substring representing a date.
    ///
    /// - Parameter rawDate: A substring representation of the date in ISO 8601 format.
    /// - Returns: An optional `End` instance if the substring is a valid date.
    public static func afterDate(_ rawDate: Substring) -> RecurrenceRule.End? {
      return .afterDate(String(rawDate))
    }

    /// The maximum number of times the event may occur.
    ///
    /// This property is `nil` if the recurrence is not constrained by the number of occurrences.
    public var occurrences: Int?

    /// The latest date on which the event may occur.
    ///
    /// This property is `nil` if the recurrence is not constrained by a specific date.
    public var date: Date?

    /// Indicates whether the recurrence has no defined end (`.never`).
    ///
    /// - Returns: `true` if the recurrence repeats indefinitely; otherwise, `false`.
    public var isNever: Bool {
      date == nil && occurrences == nil
    }

    /// Private initializer to create an `End` instance.
    ///
    /// - Parameters:
    ///   - occurrences: The maximum number of occurrences (optional).
    ///   - date: The latest date of recurrence (optional).
    private init(occurrences: Int? = nil, date: Date? = nil) {
      self.occurrences = occurrences
      self.date = date
    }
  }
}
