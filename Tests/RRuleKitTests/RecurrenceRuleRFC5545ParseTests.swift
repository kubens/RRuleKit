//
//  RecurrenceRuleRFC5545ParseTests.swift
//  RRuleKit
//
//  Created by kubens.com on 12/01/2025.
//

import Testing
import Foundation
@testable import RRuleKit

@Suite("Recurrence Rule RFC 5545 Parsing Tests")
struct RecurrenceRuleRFC5545ParseTests {

  let calendar: Calendar
  let parser: RecurrenceRuleRFC5545FormatStyle

  init() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt

    self.calendar = calendar
    self.parser = RecurrenceRuleRFC5545FormatStyle(calendar: calendar)
  }

  @Suite("FREQ Rule Part Tests")
  struct FrequencyRulePartTests {

    let parser: RecurrenceRuleRFC5545FormatStyle

    init() {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = .gmt

      self.parser = RecurrenceRuleRFC5545FormatStyle(calendar: calendar)
    }

    @Test(
      "Correctly parses valid FREQ values",
      arguments: zip(
        ["MINUTELY", "HOURLY", "DAILY", "WEEKLY", "MONTHLY", "YEARLY"],
        [Calendar.RecurrenceRule.Frequency.minutely, .hourly, .daily, .weekly, .monthly, .yearly]
      )
    )
    func supportedFrequencyValues(_ rfcFrequency: String, expected: Calendar.RecurrenceRule.Frequency) throws {
      let rfcString = "FREQ=\(rfcFrequency)"
      let result = try parser.parse(rfcString)

      #expect(result.frequency == expected)
    }

    @Test("Throws an error for invalid FREQ values")
    func invalidFrequencyValue() throws {
      #expect(throws: NSError.self) {
        try parser.parse("FREQ=FOOBAR")
      }
    }
  }

  @Suite("UNTIL and COUNT Rule Part Tests")
  struct UntilAndCountRulePartTests {

    let parser: RecurrenceRuleRFC5545FormatStyle

    init() {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = .gmt

      parser = RecurrenceRuleRFC5545FormatStyle(calendar: calendar)
    }

    @Test("Parses UNTIL as a specific end date")
    func parseUntilDate() throws {
      let rfcString = "FREQ=DAILY;UNTIL=20250111"

      let expected = Calendar.RecurrenceRule.End.afterDate(Date(timeIntervalSince1970: 1736553600))
      let result = try parser.parse(rfcString)

      #expect(result.end == expected)
    }

    @Test("Parses UNTIL with date-time strings", arguments: ["20250111T235959Z", "20250111T235959"])
    func parseUntilDateTime(dateTimeString: String) throws {
      let rfcString = "FREQ=DAILY;UNTIL=\(dateTimeString)"

      let expected = Calendar.RecurrenceRule.End.afterDate(Date(timeIntervalSince1970: 1736639999))
      let result = try parser.parse(rfcString)

      #expect(result.end == expected)
    }

    @Test("Handles UNTIL with TZID correctly")
    func parseUntilDateTimeWithTimeZone() throws {
      let rfcString = "FREQ=DAILY;UNTIL=TZID=America/New_York:20250111T235959"
      let timeZone = try #require(TimeZone(identifier: "America/New_York"))

      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = timeZone

      let parser = RecurrenceRuleRFC5545FormatStyle(calendar: calendar)
      let expected = Calendar.RecurrenceRule.End.afterDate(Date(timeIntervalSince1970: 1736657999))
      let result = try parser.parse(rfcString)

      #expect(result.end == expected)
    }

    @Test("Throws an error for invalid UNTIL values", arguments: ["20251350", "foobar", "1"])
    func invalidUntilDate(unitlString: String) throws {
      let rfcString = "FREQ=DAILY;UNTIL=\(unitlString)"

      #expect(throws: NSError.self, performing: {
        try parser.parse(rfcString)
      })
    }

    @Test("Parses COUNT as a specific occurrence limit")
    func parseCount() throws {
      let rfcString = "FREQ=DAILY;COUNT=5"

      let expected = Calendar.RecurrenceRule.End.afterOccurrences(5)
      let result = try parser.parse(rfcString)

      #expect(result.end == expected)
    }

    @Test("Throws an error for invalid COUNT values", arguments: ["-2", "1-", "foobar"])
    func invalidCount(countString: String) throws {
      let rfcString = "FREQ=DAILY;COUNT=\(countString)"

      #expect(throws: NSError.self, performing: {
        try parser.parse(rfcString)
      })
    }

    @Test("Throws an error when both UNTIL and COUNT are specified")
    func throwsErrorWhenUntilAndCountArePresent() throws {
      let rfcString = "FREQ=DAILY;UNTIL=20250111;COUNT=5"

      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }
  }

  @Suite("BY* Rule Part Tests")
  struct ByRulePartTests {

    let parser: RecurrenceRuleRFC5545FormatStyle

    init() {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = .gmt

      self.parser = RecurrenceRuleRFC5545FormatStyle(calendar: calendar)
    }

    @Test(
      "Parses valid BYMINUTE values",
      arguments: zip(
        ["BYMINUTE=0", "BYMINUTE=0,30", "BYMINUTE=0,1,2,59"],
        [[0], [0, 30], [0, 1, 2, 59]]
      )
    )
    func parseByMinute(byMinuteString: String, expected: [Int]) throws {
      let rfcString = "FREQ=DAILY;\(byMinuteString)"
      let result = try parser.parse(rfcString)

      #expect(result.minutes == expected)
    }

    @Test(
      "Throws an error for invalid BYMINUTE values",
      arguments: ["BYMINUTE=-1","BYMINUTE=60","BYMINUTE=foobar"]
    )
    func invalidByMinute(byMinuteString: String) throws {
      let rfcString = "FREQ=DAILY;\(byMinuteString)"

      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses valid BYHOUR values",
      arguments: zip(
        ["BYHOUR=0", "BYHOUR=0,12", "BYHOUR=0,1,2,23"],
        [[0], [0, 12], [0, 1, 2, 23]]
      )
    )
    func parseByHour(byHourString: String, expected: [Int]) throws {
      let rfcString = "FREQ=DAILY;\(byHourString)"
      let result = try parser.parse(rfcString)

      #expect(result.hours == expected)
    }

    @Test("Throws an error for invalid BYHOUR values", arguments: ["BYHOUR=-1", "BYHOUR=24", "BYHOUR=foobar"])
    func invalidByHour(byHourString: String) throws {
      let rfcString = "FREQ=DAILY;\(byHourString)"
      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses all weekdays in BYDAY",
      arguments: zip(
        [
          "FREQ=DAILY;BYDAY=MO",
          "FREQ=DAILY;BYDAY=TU",
          "FREQ=DAILY;BYDAY=WE",
          "FREQ=DAILY;BYDAY=TH",
          "FREQ=DAILY;BYDAY=FR",
          "FREQ=DAILY;BYDAY=SA",
          "FREQ=DAILY;BYDAY=SU",
        ],
        [
          Calendar.RecurrenceRule.Weekday.every(.monday),
          .every(.tuesday),
          .every(.wednesday),
          .every(.thursday),
          .every(.friday),
          .every(.saturday),
          .every(.sunday),
        ]
      )
    )
    func allWeekdaysByDay(rfcString: String, expected: Calendar.RecurrenceRule.Weekday) throws {
      let result = try parser.parse(rfcString)

      #expect(result.weekdays == [expected])
    }

    @Test(
      "Parses valid BYDAY values",
      arguments: zip(
        [
          "FREQ=DAILY;BYDAY=MO,1WE",
          "FREQ=DAILY;BYDAY=-1FR,MO"
        ],
        [
          [Calendar.RecurrenceRule.Weekday.every(.monday), .nth(1, .wednesday)],
          [.nth(-1, .friday), .every(.monday)]
        ]
      )
    )
    func parseByDay(byDayString: String, expected: [Calendar.RecurrenceRule.Weekday]) throws {
      let result = try parser.parse(byDayString)

      #expect(result.weekdays == expected)
    }

    @Test("Throws an error for invalid BYDAY values", arguments: ["FREQ=DAILY;BYDAY=BAR,1WE", "FREQ=DAILY;BYDAY=MO,1BAR"])
    func invalidByDay(_ byDayString: String) throws {
      #expect(throws: NSError.self) {
        try parser.parse(byDayString)
      }
    }

    @Test(
      "Parses valid BYMONTHDAY values",
      arguments: zip(
        ["BYMONTHDAY=1", "BYMONTHDAY=-31", "BYMONTHDAY=1,15,31"],
        [[1], [-31], [1, 15, 31]]
      )
    )
    func parseByMonthDay(byMonthDay: String, expected: [Int]) throws {
      let rfcString = "FREQ=MONTHLY;\(byMonthDay)"
      let result = try parser.parse(rfcString)

      #expect(result.daysOfTheMonth == expected)
    }

    @Test(
      "Throws an error for invalid BYMONTHDAY values",
      arguments: ["BYMONTHDAY=-32", "BYMONTHDAY=32", "BYMONTHDAY=foobar"]
    )
    func invalidByMonthDay(byMonthDay: String) throws {
      let rfcString = "FREQ=MONTHLY;\(byMonthDay)"

      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses valid BYYEARDAY values",
      arguments: zip(
        ["BYYEARDAY=1", "BYYEARDAY=-366", "BYYEARDAY=1,100,366"],
        [[1], [-366], [1, 100, 366]]
      )
    )
    func parseByYearDay(byYearDay: String, expected: [Int]) throws {
      let rfcString = "FREQ=YEARLY;\(byYearDay)"
      let result = try parser.parse(rfcString)

      #expect(result.daysOfTheYear == expected)
    }

    @Test(
      "Throws an error for invalid BYYEARDAY values",
      arguments: ["BYYEARDAY=-367", "BYYEARDAY=367", "BYYEARDAY=foobar"]
    )
    func invalidByYearDay(byYearDay: String) throws {
      let rfcString = "FREQ=YEARLY;\(byYearDay)"
      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses valid BYWEEKNO values",
      arguments: zip(
        ["BYWEEKNO=1", "BYWEEKNO=-53", "BYWEEKNO=1,10,53"],
        [[1], [-53], [1, 10, 53]]
      )
    )
    func parseByWeekNo(byWeekNo: String, expected: [Int]) throws {
      let rfcString = "FREQ=YEARLY;\(byWeekNo)"
      let result = try parser.parse(rfcString)

      #expect(result.weeks == expected)
    }

    @Test(
      "Throws an error for invalid BYWEEKNO values",
      arguments: ["BYWEEKNO=-54", "BYWEEKNO=54", "BYWEEKNO=foobar"]
    )
    func invalidByWeekNo(byWeekNo: String) throws {
      let rfcString = "FREQ=YEARLY;\(byWeekNo)"
      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses valid BYMONTH values",
      arguments: zip(
        ["BYMONTH=1", "BYMONTH=1,6,12"],
        [[Calendar.RecurrenceRule.Month(1)], [1, 6, 12]]
      )
    )
    func parseByMonth(byMonth: String, expected: [Calendar.RecurrenceRule.Month]) throws {
      let rfcString = "FREQ=YEARLY;\(byMonth)"
      let result = try parser.parse(rfcString)

      #expect(result.months == expected)
    }

    @Test("Throws an error for invalid BYMONTH values", arguments: ["BYMONTH=0", "BYMONTH=13", "BYMONTH=foobar"])
    func invalidByMonth(byMonth: String) throws {
      let rfcString = "FREQ=YEARLY;\(byMonth)"

      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }

    @Test(
      "Parses valid BYSETPOS values",
      arguments: zip(
        ["BYSETPOS=1", "BYSETPOS=-5", "BYSETPOS=1,2,-1"],
        [[1], [-5], [1, 2, -1]]
      )
    )
    func parseBySetPos(bySetPos: String, expected: [Int]) throws {
      let rfcString = "FREQ=MONTHLY;\(bySetPos)"
      let result = try parser.parse(rfcString)

      #expect(result.setPositions == expected)
    }

    @Test(
      "Throws an error for invalid BYSETPOS values",
      arguments: ["BYSETPOS=-367", "BYSETPOS=367", "BYSETPOS=foobar"]
    )
    func invalidBySetPos(bySetPos: String) throws {
      let rfcString = "FREQ=MONTHLY;\(bySetPos)"
      #expect(throws: NSError.self) {
        try parser.parse(rfcString)
      }
    }
  }

  @Test("Throws an error for invalid RFC 5545 string formats", arguments: [
    "", "FOO=BAR", "COUNT=1", "FREQ=MONTHLY:COUNT=2", "FREQ=MONTHLY;BYDAY=MO;WE"
  ])
  func invalidRFC5545StringFormat(rfcString: String) throws {
    #expect(throws: NSError.self) {
      try parser.parse(rfcString)
    }
  }

  @Test("Parses valid RFC 5545 string with multiple rule parts")
  func validCombinedRuleParts() throws {
    let rfcString = "FREQ=MONTHLY;BYDAY=MO,TU;BYMONTH=1,6;BYSETPOS=1,-1;COUNT=5"

    let result = try parser.parse(rfcString)
    let expected = Calendar.RecurrenceRule(
      calendar: calendar,
      frequency: .monthly,
      end: .afterOccurrences(5),
      months: [1, 6],
      weekdays: [.every(.monday), .every(.tuesday)],
      setPositions: [1, -1]
    )

    #expect(result == expected)
  }

  @Test(
    "Throws an error for duplicate keys in the RFC 5545 string",
    arguments: ["FREQ=DAILY;FREQ=WEEKLY;COUNT=5", "FREQ=DAILY;COUNT=4;COUNT=5"]
  )
  func invalidDuplicateKeys(rfcString: String) throws {
    #expect(throws: NSError.self) {
      try parser.parse(rfcString)
    }
  }
}
