//
//  Filter.swift
//  RRuleKit
//
//  Created by kubens.com on 05/01/2025.
//

import Foundation

/// A protocol that defines a filter for dates.
///
/// Types conforming to the `Filter` protocol can implement custom logic
/// to evaluate whether a given date matches specific criteria. This can be
/// used for filtering dates in various contexts, such as recurrence rules,
/// event scheduling, or custom date-based queries.
public protocol Filter {

  /// Determines whether a given date matches the filter's criteria.
  ///
  /// - Parameters:
  ///   - date: The `Date` to evaluate.
  ///   - calendar: The `Calendar` to use for date calculations and comparisons.
  /// - Returns: `true` if the date matches the filter's criteria; otherwise, `false`.
  func matches(date: Date, in calendar: Calendar) -> Bool
}
