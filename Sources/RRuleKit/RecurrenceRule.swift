//
//  RecurrenceRule.swift
//  RRuleKit
//
//  Created by kubens.com on 01/01/2025.
//

import Foundation

/// A rule which specifies how often an event should repeat in the future.
public struct RecurrenceRule: Equatable, Sendable {

  /// The frequency of the recurrence (e.g., daily, weekly, monthly, etc.).
  public var frequency: RecurrenceRule.Frequency

  /// The interval at which the recurrence repeats.
  ///
  /// For example, an interval of `2` and a frequency of `.weekly` means the event occurs every 2 weeks.
  ///
  /// - Default: `1`
  public var interval: Int = 1

  /// The condition that determines when the recurrence ends.
  ///
  /// This can specify a fixed number of occurrences, a specific date, or no end at all.
  ///
  /// - Default: `.never`
  public var end: RecurrenceRule.End = .never

  /// The days of the week on which the event occurs.
  public var daysOfTheWeek: [RecurrenceRule.DayOfWeek] = []

  /// The months of the year in which the event occurs.
  ///
  /// Months are represented as integers, where `1` is January, `2` is February, and so on.
  public var monthsOfTheYear: [RecurrenceRule.Month] = []

  /// The days of the month on which the event occurs.
  ///
  /// Positive values indicate specific days (e.g., `1` is the first day of the month), while negative
  /// values indicate counting backward (e.g., `-1` is the last day of the month).
  /// - Note: This field is unused when `frequency` is `.weekly`.
  public var daysOfTheMonth: [Int] = []

  /// The weeks of the year during which the event occurs.
  ///
  /// Weeks are represented as integers, with `1` being the first week of the year.
  /// - Note: This field is unused when `frequency` is other than `.yearly`.
  public var weeksOfTheYear: [Int] = []

  /// The days of the year on which the event occurs.
  ///
  /// Positive values indicate specific days (e.g., `1` is January 1st), while negative
  /// values indicate counting backward (e.g., `-1` is December 31st).
  /// - Note: This field is unused when `frequency` is any of `.daily`, `.weekly`, or `.monthly`.
  public var daysOfTheYear: [Int] = []

  /// The positions within each interval to include in the recurrence.
  ///
  /// For example, `[1, -1]` specifies the first and last occurrences within the interval.
  public var setPositions: [Int] = []

  // MARK: - Occurrences

  /// Generates a sequence of occurrence dates based on the recurrence rule.
  ///
  /// This method computes all the dates defined by the recurrence rule that fall between
  /// a given start date and an optional end date, up to a specified limit.
  ///
  /// - Parameters:
  ///   - startDate: The date from which to start generating occurrences.
  ///   - endDate: An optional end date. If provided, occurrences after this date will be excluded. Defaults to `nil`.
  ///   - limit: The maximum number of dates to generate. Defaults to `366`.
  /// - Returns: An array of `Date` values representing the occurrences.
  public func occurrences(from startDate: Date, until endDate: Date? = nil, limit: Int = 366) -> [Date] {
    guard limit > 0, var iterator = makeIterator(for: startDate) else { return [] }
    var results: [Date] = []

    while let nextDate = iterator.next() {
      if let endDate, nextDate > endDate { break }
      results.append(nextDate)

      if results.count >= limit {
        break
      }
    }

    return results
  }

  /// Generates occurrences of dates that fall within a specified range.
  ///
  /// This method computes all the dates defined by the recurrence rule that fall
  /// within the bounds of the provided date range.
  ///
  /// - Parameter range: A `ClosedRange<Date>` representing the start and end dates for the range.
  /// - Returns: An array of `Date` values representing the occurrences within the range.
  public func occurences(in range: ClosedRange<Date>) -> [Date] {
    return occurrences(from: range.lowerBound, until: range.upperBound)
  }

  // MARK: Helpers

  private func makeIterator(for startDate: Date) -> (any RecurrenceRuleIterator)? {
    switch frequency {
    case .weekly: WeeklyIterator(rrule: self, from: startDate, in: .current)
    default: nil
    }
  }
}

// MARK: - RawRepresentable
extension RecurrenceRule: RawRepresentable {

  /// A string representation of the recurrence rule in iCalendar (RFC 5545) format.
  ///
  /// For example: `"FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR"`.
  public var rawValue: String {
    var components = ["FREQ=\(frequency.rawValue)"]

    if interval > 1 {
      components.append("INTERVAL=\(interval)")
    }

    if let count = end.occurrences {
      components.append("COUNT=\(count)")
    } else if let until = end.date {
      components.append("UNTIL=\(until.ISO8601Format())")
    }

    if daysOfTheWeek.count > 0 {
      let byDay = daysOfTheWeek.map(\.rawValue).joined(separator: ",")
      components.append("BYDAY=\(byDay)")
    }

    if monthsOfTheYear.count > 0 {
      let byMonth = monthsOfTheYear.map({ "\($0.rawValue)" }).joined(separator: ",")
      components.append("BYMONTH=\(byMonth)")
    }

    if daysOfTheMonth.count > 0 {
      let byMonthDay = daysOfTheMonth.map(String.init).joined(separator: ",")
      components.append("BYMONTHDAY=\(byMonthDay)")
    }

    if weeksOfTheYear.count > 0 {
      let byWeekNo = weeksOfTheYear.map(String.init).joined(separator: ",")
      components.append("BYWEEKNO=\(byWeekNo)")
    }

    if daysOfTheYear.count > 0 {
      let byYearDay = daysOfTheYear.map(String.init).joined(separator: ",")
      components.append("BYYEARDAY=\(byYearDay)")
    }

    if setPositions.count > 0 {
      let bySetPos = setPositions.map(String.init).joined(separator: ",")
      components.append("BYSETPOS=\(bySetPos)")
    }

    return components.joined(separator: ";")
  }

  /// Initializes a `RecurrenceRule` from its string representation.
  ///
  /// - Parameter rawValue: A string in iCalendar format.
  public init?(rawValue: String) {
    let components = rawValue.split(separator: ";")
    var frequency: RecurrenceRule.Frequency?

    for component in components {
      let pair = component.split(separator: "=")
      guard pair.count == 2 else { continue }
      let key = pair[0]
      let value = pair[1]

      switch key {
      case "FREQ": frequency = RecurrenceRule.Frequency(value)
      case "INTERVAL": interval = Int(value) ?? 1
      case "COUNT": end = .afterOccurrences(value) ?? .never
      case "UNTIL": end = .afterDate(value) ?? .never
      case "BYDAY": daysOfTheWeek = value.split(separator: ",").compactMap({ RecurrenceRule.DayOfWeek($0) })
      case "BYMONTH": monthsOfTheYear = value.split(separator: ",").compactMap({ RecurrenceRule.Month($0) })
      case "BYMONTHDAY": daysOfTheMonth = value.split(separator: ",").compactMap({ Int($0) })
      case "BYWEEKNO": weeksOfTheYear = value.split(separator: ",").compactMap({ Int($0) })
      case "BYYEARDAY": daysOfTheYear = value.split(separator: ",").compactMap({ Int($0) })
      case "BYSETPOS": setPositions = value.split(separator: ",").compactMap({ Int($0) })
      default: continue
      }
    }

    guard let frequency else { return nil }
    self.frequency = frequency
  }
}

// MARK: - Codable
extension RecurrenceRule: Codable {

  /// Decodes a `RecurrenceRule` from its iCalendar (RFC 5545) string representation.
  ///
  /// - Parameter decoder: The decoder to read data from.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawString = try container.decode(String.self)
    guard let rule = RecurrenceRule(rawValue: rawString) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid recurrence rule: \(rawString)")
    }
    self = rule
  }

  /// Encodes a `RecurrenceRule` to its iCalendar (RFC 5545) string representation.
  ///
  /// - Parameter encoder: The encoder to write data to.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
}
