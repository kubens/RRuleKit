//
//  RRuleIterator.swift
//  RRuleKit
//
//  Created by kubens.com on 06/01/2025.
//

import Foundation

/// A protocol for iterators that generate dates based on a recurrence rule.
///
/// The `RRuleIterator` protocol defines the requirements for creating iterators
/// that produce dates in a sequence defined by a recurrence rule. Conforming types must support
/// customizable parameters such as interval, end conditions, and filters.
///
/// This protocol is designed for iterating over recurring dates in various recurrence patterns,
/// such as daily, weekly, or monthly schedules.
public protocol RRuleIterator: IteratorProtocol<Date> {

  /// The calendar used for date calculations.
  var calendar: Calendar { get }

  /// The interval between occurrences in the recurrence rule.
  var interval: Int { get }

  /// The condition that determines when the recurrence ends.
  ///
  /// This can be defined by:
  /// - A specific number of occurrences.
  /// - An end date after which no more occurrences are generated.
  var recurrenceEnd: RRule.End { get }

  /// Filters applied to the iterator to refine the dates that match the recurrence rule.
  ///
  /// These filters allow additional constraints, such as specific days of the week or custom date conditions.
  var filters: [any Filter] { get }

  /// Creates a new recurrence rule iterator based on the provided recurrence rule.
  ///
  /// - Parameters:
  ///   - rrule: The `RRule` defining the recurrence pattern.
  ///   - startDate: The date from which to start the iteration.
  ///   - calendar: The calendar to use for date calculations.
  ///
  /// - Note: An optional instance of a `RRuleIterator`. Returns `nil` if the `RRule` is incompatible
  ///   with the iterator (e.g., a daily iterator cannot handle a weekly frequency).
  init?(rrule: RRule, from startDate: Date, in calendar: Calendar)
}
