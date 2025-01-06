//
//  WeeklyIterator.swift
//  RRuleKit
//
//  Created by kubens.com on 06/01/2025.
//

import Foundation

/// An iterator that generates dates for a weekly recurrence rule.
///
/// The `WeeklyIterator` produces dates based on a recurrence rule's weekly frequency, interval,
/// and end conditions (e.g., maximum occurrences or an end date). It also supports filtering
/// based on specific days of the week.
///
/// This iterator is designed to work seamlessly with the `IteratorProtocol`, allowing iteration
/// over dates in a weekly recurrence pattern.
public struct WeeklyIterator: RRuleIterator {

  /// The calendar used for date calculations.
  public let calendar: Calendar

  /// The interval between each recurrence, in weeks.
  public let interval: Int

  /// The condition that determines when the recurrence ends.
  public let recurrenceEnd: RRule.End

  /// Filters applied to determine if a date satisfies the recurrence rule.
  ///
  /// These filters can include constraints like specific days of the week.
  public let filters: [any Filter]

  /// The current date in the iteration.
  ///
  /// This property tracks the progress of the iterator.
  private var currentDate: Date

  /// The number of occurrences generated so far.
  private var occurencesCount: Int

  /// Creates a new `WeeklyIterator` from a `RRule`.
  ///
  /// This initializer only succeeds if the frequency of the recurrence rule is `.weekly`.
  ///
  /// - Parameters:
  ///   - rrule: The `RRule` to use for the iteration.
  ///   - startDate: The starting date for the iteration. Defaults to the current date.
  ///   - calendar: The calendar to use for date calculations. Defaults to `.current`.
  public init?(rrule: RRule, from startDate: Date = .now, in calendar: Calendar = .current) {
    guard rrule.frequency == .weekly else { return nil }
    var filters: [any Filter] = []

    if rrule.daysOfTheWeek.count > 0 {
      filters.append(ByWeekdayFilter(daysOfTheWeek: rrule.daysOfTheWeek, useOrdinal: false))
    } else if let weekday = RRule.Weekday(startDate, in: calendar) {
      filters.append(ByWeekdayFilter(daysOfTheWeek: [.every(weekday: weekday)], useOrdinal: false))
    } else {
      return nil
    }

    self.calendar = calendar
    self.interval = rrule.interval
    self.recurrenceEnd = rrule.end
    self.filters = filters
    self.currentDate = startDate
    self.occurencesCount = 0
  }

  /// Advances to the next date in the weekly recurrence sequence.
  ///
  /// This method generates the next date that satisfies the recurrence rule's criteria.
  /// It stops iteration when the end condition (number of occurrences or end date) is met.
  ///
  /// - Returns: The next date in the recurrence sequence, or `nil` if the iteration has ended.
  public mutating func next() -> Date? {
    while true {
      if let occurrences = recurrenceEnd.occurrences, occurencesCount >= occurrences { return nil }
      if let until = recurrenceEnd.date, currentDate > until { return nil }

      let potentialDate = currentDate
      currentDate = calculateNextDate(form: currentDate)!

      if filters.allSatisfy({ $0.matches(date: potentialDate, in: calendar) }) {
        occurencesCount += 1
        return potentialDate
      }
    }
  }

  /// Calculates the next potential date in the iteration.
  ///
  /// This method determines the next date based on the calendar and interval.
  ///
  /// - Parameter date: The current date in the iteration.
  /// - Returns: The next potential date.
  private func calculateNextDate(form date: Date) -> Date? {
    let value = calendar.isLastWeekday(date) ? (1 + (interval - 1) * 7) : 1
    return calendar.date(byAdding: .day, value: value, to: date)
  }
}
