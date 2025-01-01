//
//  RecurrenceRule+Weekday.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

extension RecurrenceRule {

  /// Represents the days of the week for a recurrence rule.
  ///
  /// Each case corresponds to a day of the week,
  /// represented by its standard two-letter abbreviation as used in iCalendar rules.
  public enum Weekday: String, RawRepresentable, Sendable {

    /// Represents Monday (`"MO"`).
    case monday = "MO"

    /// Represents Tuesday (`"TU"`).
    case tuesday = "TU"

    /// Represents Wednesday (`"WE"`).
    case wednesday = "WE"

    /// Represents Thursday (`"TH"`).
    case thursday = "TH"

    /// Represents Friday (`"FR"`).
    case friday = "FR"

    /// Represents Saturday (`"SA"`).
    case saturday = "SA"

    /// Represents Sunday (`"SU"`).
    case sunday = "SU"

    /// Initializes a `Weekday` from its raw string value.
    ///
    /// - Parameter rawValue: The two-letter abbreviation for the day of the week (e.g., `"MO"`, `"TU"`).
    /// - Returns: An optional `Weekday` if the raw value matches one of the cases; otherwise, `nil`.
    public init?(_ rawValue: String) {
      self.init(rawValue: rawValue)
    }

    /// Initializes a `Weekday` from a substring representation of its raw value.
    ///
    /// - Parameter rawValue: A substring representation of the two-letter abbreviation for the day of the week.
    /// - Returns: An optional `Weekday` if the substring matches one of the cases; otherwise, `nil`.
    public init?(_ rawValue: Substring) {
      self.init(rawValue: String(rawValue))
    }
  }
}
