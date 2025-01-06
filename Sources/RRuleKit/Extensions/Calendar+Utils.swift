//
//  Calendar+Utils.swift
//  RRuleKit
//
//  Created by kubens.com on 06/01/2025.
//

import Foundation

internal extension Calendar {

  /// The last weekday of the week for the calendar.
  ///
  /// This is calculated based on the `firstWeekday` property of the calendar.
  var lastWeekday: Int {
    (firstWeekday + 6 - 1) % 7 + 1
  }

  /// Checks whether a given date falls on the first weekday of the calendar.
  ///
  /// - Parameter date: The `Date` to check.
  /// - Returns: `true` if the date falls on the first weekday; otherwise, `false`.
  func isFirstWeekday(_ date: Date) -> Bool {
    let weekday = component(.weekday, from: date)
    return weekday == firstWeekday
  }

  /// Checks whether a given date falls on the last weekday of the calendar.
  ///
  /// - Parameter date: The `Date` to check.
  /// - Returns: `true` if the date falls on the last weekday; otherwise, `false`.
  func isLastWeekday(_ date: Date) -> Bool {
    let weekday = component(.weekday, from: date)
    return weekday == lastWeekday
  }
}
