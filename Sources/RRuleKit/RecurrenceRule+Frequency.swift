//
//  RecurrenceRule+Frequency.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

extension RecurrenceRule {

  /// Represents the frequency of a recurrence rule.
  ///
  /// The frequency determines the unit of time over which an event recurs. For example:
  /// - `daily`: The event recurs every day.
  /// - `weekly`: The event recurs every week.
  /// - `monthly`: The event recurs every month.
  /// - `yearly`: The event recurs every year.
  public enum Frequency: String, Sendable {

    /// Indicates a daily recurrence rule.
    ///
    /// For example, an event with a `daily` frequency will occur once every day.
    case daily = "DAILY"

    /// Indicates a weekly recurrence rule.
    ///
    /// For example, an event with a `weekly` frequency will occur once every week.
    case weekly = "WEEKLY"

    /// Indicates a monthly recurrence rule.
    ///
    /// For example, an event with a `monthly` frequency will occur once every month.
    case monthly = "MONTHLY"

    /// Indicates a yearly recurrence rule.
    ///
    /// For example, an event with a `yearly` frequency will occur once every year.
    case yearly = "YEARLY"

    /// Initializes a `Frequency` from a raw string value.
    ///
    /// - Parameter rawValue: A string representation of the frequency (e.g., `"DAILY"`, `"WEEKLY"`).
    public init?(_ rawValue: String) {
      self.init(rawValue: rawValue)
    }

    /// Initializes a `Frequency` from a raw substring value.
    ///
    /// - Parameter rawValue: A substring representation of the frequency.
    public init?(_ rawValue: Substring) {
      self.init(rawValue: String(rawValue))
    }
  }
}
