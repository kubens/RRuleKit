//
//  ByWeekdayFilterTests.swift
//  RRuleKit
//
//  Created by kubens.com on 05/01/2025.
//

import Testing
import Foundation
@testable import RRuleKit

@Suite("ByWeekdayFilter")
struct ByDayFilterTests {

  let calendar = Calendar.current

  @Test("matches every weekday")
  func matchesEveryWeekday() {
    let filter = ByWeekdayFilter(daysOfTheWeek: [.every(weekday: .wednesday)])
    let date = calendar.date(from: .init(year: 2025, month: 1, day: 1))!

    #expect(filter.matches(date: date, in: calendar) == true)
  }

  @Test("matches first weekday")
  func matchesFirstWeekday() throws {
    let filter = ByWeekdayFilter(daysOfTheWeek: [.first(weekday: .wednesday)])
    let date = calendar.date(from: .init(year: 2025, month: 1, day: 1))!

    #expect(filter.matches(date: date, in: calendar))
  }

  @Test("matches nth weekday")
  func matchesNthWeekday() throws {
    let filter = ByWeekdayFilter(daysOfTheWeek: [.nth(2, weekday: .wednesday)])
    let date = calendar.date(from: .init(year: 2025, month: 1, day: 8))!

    #expect(filter.matches(date: date, in: calendar))
  }

  @Test("matches negative nth weekday")
  func matchesNegativeNthWeekday() throws {
    let filter = ByWeekdayFilter(daysOfTheWeek: [.nth(-1, weekday: .wednesday)])
    let date = calendar.date(from: .init(year: 2025, month: 1, day: 29))!

    #expect(filter.matches(date: date, in: calendar))
  }
}
