//
//  RecurrenceRule+Month.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

extension RecurrenceRule {

  /// Represents the months of the year for a recurrence rule.
  ///
  /// Each case corresponds to a month, with January represented by `1` and December by `12`.
  public enum Month: Int, RawRepresentable, Equatable, Sendable {

    /// Represents January (1).
    case january = 1

    /// Represents February (2).
    case february = 2

    /// Represents March (3).
    case march = 3

    /// Represents April (4).
    case april = 4

    /// Represents May (5).
    case may = 5

    /// Represents June (6).
    case June = 6

    /// Represents July (7).
    case july = 7

    /// Represents August (8).
    case august = 8

    /// Represents September (9).
    case september = 9

    /// Represents October (10).
    case october = 10

    /// Represents November (11).
    case november = 11

    /// Represents December (12).
    case december = 12

    /// Initializes a `Month` from its raw integer value.
    ///
    /// - Parameter rawValue: The integer representation of the month (1–12).
    /// - Returns: An optional `Month` if the value matches one of the cases; otherwise, `nil`.
    public init?(_ rawValue: Int) {
      self.init(rawValue: rawValue)
    }

    /// Initializes a `Month` from a string representation of its raw value.
    ///
    /// - Parameter rawValue: A string representation of the month's integer value (e.g., `"1"`, `"12"`).
    /// - Returns: An optional `Month` if the string represents a valid month; otherwise, `nil`.
    public init?(_ rawValue: String) {
      guard let value = Int(rawValue) else { return nil }
      self.init(rawValue: value)
    }

    /// Initializes a `Month` from a substring representation of its raw value.
    ///
    /// - Parameter rawValue: A substring representation of the month's integer value.
    /// - Returns: An optional `Month` if the substring represents a valid month; otherwise, `nil`.
    public init?(_ rawValue: Substring) {
      self.init(String(rawValue))
    }
  }
}
