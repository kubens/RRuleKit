//
//  RecurrenceRuleRFC5545FormatStyle.swift
//  RRuleKit
//
//  Created by kubens.com on 11/01/2025.
//

import Foundation

public struct RecurrenceRuleRFC5545FormatStyle: Sendable {

  /// The typealias for `Calendar.RecurrenceRule`, representing the recurrence rule.
  public typealias RecurrenceRule = Calendar.RecurrenceRule

  /// The calendar used for parsing and validating recurrence rules.
  public let calendar: Calendar

  /// Initializes the format style with a specific calendar.
  ///
  /// - Parameter calendar: The calendar to use for parsing. Defaults to `.current`.
  public init(calendar: Calendar = .current) {
    self.calendar = calendar
  }
}

// MARK: - ParseStrategy
extension RecurrenceRuleRFC5545FormatStyle: ParseStrategy {

  /// Parses an RFC 5545-compliant string into a `RecurrenceRule`.
  ///
  /// - Parameter rfcString: The input RFC 5545 string.
  /// - Returns: A `RecurrenceRule` if parsing is successful.
  ///
  /// ## RFC 5545 Parsing Requirements:
  ///   The `FREQ` key is **mandatory** and defines the recurrence frequency.
  ///   **`FREQ` must appear as the first key** in the string.
  ///
  ///   Optional keys include:
  ///   - `COUNT`: Specifies the number of occurrences.
  ///   - `UNTIL`: Defines the end date of the recurrence in either UTC or local time.
  ///   - `INTERVAL`: Specifies the interval between occurrences (default is 1).
  ///   - `BY*` keys (e.g., `BYSECOND`, `BYDAY`): Define specific occurrences within the recurrence pattern.
  ///   - Keys must be separated by semicolons (`;`) and formatted as `KEY=VALUE`.
  ///   - Only one of `COUNT` or `UNTIL` can be present in a single rule.
  ///
  /// - Note: The input string must follow strict RFC 5545 formatting.
  ///   Invalid or unsupported keys will cause parsing to fail.
  ///
  /// - Warning: **The `FREQ=SECONDLY` frequency is currently not supported.**
  ///   If the input string specifies `FREQ=SECONDLY`, the function throw error.
  ///
  /// See also: [RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10)
  public func parse(_ rfcString: String) throws -> RecurrenceRule {
    guard let (_, rrule) = parse(rfcString, in: rfcString.startIndex..<rfcString.endIndex) else {
      throw self.parseError(rfcString, exampleFormattedString: "FREQ=MINUTELY")
    }

    return rrule
  }

  /// Parses an RFC 5545 recurrence rule string into a `RecurrenceRule`.
  ///
  /// - Parameters:
  ///   - value: The input RFC 5545 string to parse.
  ///   - range: The range within the string to parse.
  /// - Returns: A tuple containing the final parsing position and the `RecurrenceRule` object if parsing succeeds; otherwise, `nil`.
  ///
  /// ## Parsing Details:
  /// The `FREQ` key is **mandatory** and must be the first key.
  /// Other optional keys include:
  ///   - `UNTIL`: Specifies the end date of the recurrence in either UTC or local time.
  ///   - `COUNT`: Specifies the number of occurrences.
  ///   - `INTERVAL`: Specifies the interval between occurrences (default is 1).
  ///   - `BY*` keys (e.g., `BYSECOND`, `BYDAY`): Define specific occurrences within the recurrence pattern.
  ///
  /// Keys must be separated by semicolons (`;`) and formatted as `KEY=VALUE`.
  /// Only one of `UNTIL` or `COUNT` can be present in the rule.
  /// The input string must follow strict RFC 5545 formatting. Any invalid or unsupported key-value pair will cause parsing to fail.
  ///
  /// ## Validation:
  /// Values are validated against their respective ranges:
  ///   - `BYSECOND`: Values must be in the range [0, 60].
  ///   - `BYMINUTE`: Values must be in the range [0, 59].
  ///   - `BYHOUR`: Values must be in the range [0, 23].
  ///   - `BYMONTH`: Values must be in the range [1, 12].
  ///   - `BYDAY`: Days are validated against valid weekday codes.
  ///   - `BYMONTHDAY`: Values must be in the range [-31, 31].
  ///   - `BYYEARDAY`: Values must be in the range [-366, 366].
  ///   - `BYWEEKNO`: Values must be in the range [-53, 53].
  ///   - `BYSETPOS`: Values must be in the range [-366, 366].
  ///
  /// - Note: If multiple `BY*` keys are specified, they refine the rule by narrowing down matching occurrences.
  ///   Currently, the frequency `FREQ=SECONDLY` is not supported.
  ///
  /// - Warning: Ensure that `FREQ` is the first key in the input string. Only one of `UNTIL` or `COUNT` is allowed;
  ///   using both will cause parsing to fail.
  ///
  /// - See also: [RFC 5545 Section 3.3.10](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10)
  package func parse(_ value: String, in range: Range<String.Index>) -> (String.Index, RecurrenceRule)? {
    var v = value[range]
    guard !v.isEmpty else { return nil }

    // Parse the UTF-8 representation of the input string.
    let result = v.withUTF8 { buffer -> (Int, RecurrenceRule)? in
      var index = buffer.startIndex

      // Parse the mandatory "FREQ" key.
      guard let (keySlice, valueSlice) = extractRulePart(&index, from: buffer),
            keySlice.contains("FREQ".utf8),
            let frequency = parseAsFrequency(valueSlice) else {
        return nil
      }

      // Initialize the recurrence rule with the parsed frequency.
      var rrule = RecurrenceRule(calendar: calendar, frequency: frequency)

      // Parse remaining key-value pairs.
      while index < buffer.endIndex {
        guard let (keySlice, valueSlice) = extractRulePart(&index, from: buffer) else {
          return nil
        }

        switch keySlice.count {
        case 5 where keySlice.elementsEqual("UNTIL".utf8):
          guard let until = parseAsDate(valueSlice), rrule.end == .never else { return nil }
          rrule.end = .afterDate(until)

        case 5 where keySlice.elementsEqual("COUNT".utf8):
          guard let occurrences = parseAsInt(valueSlice, min: 1), rrule.end == .never else { return nil }
          rrule.end = .afterOccurrences(occurrences)

        case 8 where keySlice.elementsEqual("INTERVAL".utf8):
          guard let interval = parseAsInt(valueSlice, min: 1) else { return nil }
          rrule.interval = interval

        case 8 where keySlice.elementsEqual("BYSECOND".utf8):
          guard let seconds = parseAsList(valueSlice, transform: { parseAsInt($0, min: 0, max: 60) }) else { return nil }
          rrule.seconds = seconds

        case 8 where keySlice.elementsEqual("BYMINUTE".utf8):
          guard let minutes = parseAsList(valueSlice, transform: { parseAsInt($0, min: 0, max: 59) }) else { return nil }
          rrule.minutes = minutes

        case 6 where keySlice.elementsEqual("BYHOUR".utf8):
          guard let hours = parseAsList(valueSlice, transform: { parseAsInt($0, min: 0, max: 23) }) else { return nil }
          rrule.hours = hours

        case 5 where keySlice.elementsEqual("BYDAY".utf8):
          guard let weekdays = parseAsList(valueSlice, transform: { parseAsWeekday($0) })else { return nil }
          rrule.weekdays = weekdays

        case 10 where keySlice.elementsEqual("BYMONTHDAY".utf8):
          let daysOfTheMonth = parseAsList(valueSlice) { parseAsInt($0, min: -31, max: 31) }
          guard let daysOfTheMonth, daysOfTheMonth.count > 0 else { return nil }
          rrule.daysOfTheMonth = daysOfTheMonth

        case 9 where keySlice.elementsEqual("BYYEARDAY".utf8):
          let daysOfTheYear = parseAsList(valueSlice) { parseAsInt($0, min: -366, max: 366) }
          guard let daysOfTheYear, daysOfTheYear.count > 0 else { return nil }
          rrule.daysOfTheYear = daysOfTheYear

        case 8 where keySlice.elementsEqual("BYWEEKNO".utf8):
          let weeks = parseAsList(valueSlice) { parseAsInt($0, min: -53, max: 53) }
          guard let weeks else { return nil }
          rrule.weeks = weeks

        case 7 where keySlice.elementsEqual("BYMONTH".utf8):
          let months: [RecurrenceRule.Month]? = parseAsList(valueSlice) { elementSlice in
            guard let index = parseAsInt(elementSlice, min: 1, max: 12) else { return nil }
            return RecurrenceRule.Month(index)
          }

          guard let months else { return nil }
          rrule.months = months

        case 8 where keySlice.elementsEqual("BYSETPOS".utf8):
          let setPositions = parseAsList(valueSlice) { parseAsInt($0, min: -366, max: 366) }
          guard let setPositions else { return nil }
          rrule.setPositions = setPositions

        default:
          return nil
        }
      }

      return (index, rrule)
    }

    // Compute the final index after parsing.
    guard let result else { return nil }
    let endIndex = value.utf8.index(v.startIndex, offsetBy: result.0)
    return (endIndex, result.1)
  }

  /// Extracts a key-value pair from the given buffer.
  /// This function reads a key-value pair from the buffer in the format `key=value`,
  /// advancing the `index` past the parsed pair. The `key` and `value` are returned
  /// as slices of the buffer to avoid unnecessary memory allocation or copying.
  ///
  /// - Parameters:
  ///   - index: An inout parameter that tracks the current position in the buffer.
  ///     This value is updated as the function processes the key-value pair.
  ///   - buffer: The buffer containing the raw UTF-8 data to be parsed.
  ///
  /// - Returns: A tuple containing:
  ///   - `keySlice`: A slice of the buffer representing the key.
  ///   - `valueSlice`: A slice of the buffer representing the value.
  ///   Returns `nil` if the end of the buffer is reached before a complete key-value pair is found.
  @inline(__always)
  private func extractRulePart(_ index: inout Int, from buffer: UnsafeBufferPointer<UInt8>) -> (Slice<UnsafeBufferPointer<UInt8>>, Slice<UnsafeBufferPointer<UInt8>>)? {

    // Mark the start of the key.
    let keyStart = index
    while index < buffer.endIndex, buffer[index] != UInt8(ascii: "=") {
      index += 1
    }

    // If the buffer ends before finding '=', return nil.
    guard index < buffer.endIndex else {
      return nil
    }

    let keySlice = buffer[keyStart..<index]

    // Move the index past the '=' separator.
    index += 1

    // Mark the start of the value.
    let valueStart = index
    while index < buffer.endIndex, buffer[index] != UInt8(ascii: ";") {
      index += 1
    }

    let valueSlice = buffer[valueStart..<index]

    // Move after ';' if necessary
    if index < buffer.endIndex, buffer[index] == UInt8(ascii: ";") {
      index += 1
    }

    return (keySlice, valueSlice)
  }

  /// Parses a slice of a buffer as an integer value.
  /// This function converts a sequence of ASCII-encoded digits in the buffer slice
  /// into an `Int`. It also handles negative numbers if the slice begins with a `-`.
  ///
  /// - Parameter bufferSlice: A slice of an `UnsafeBufferPointer<UInt8>` containing ASCII digits,
  ///   optionally preceded by a `-` for negative numbers.
  /// - Returns: An `Int` representing the parsed number, or `nil` if the slice contains invalid characters.
  private func parseAsInt(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>, min: Int? = nil, max: Int? = nil) -> Int? {
    var result: Int = 0
    var isNegative = false
    var index = bufferSlice.startIndex

    // Check for a leading negative sign and adjust the starting index.
    if bufferSlice[index] == UInt8(ascii: "-") {
      isNegative = true
      index += 1
    }

    // Iterate over each byte in the slice.
    while index < bufferSlice.endIndex {
      let byte = bufferSlice[index]

      // Validate that the byte represents an ASCII digit.
      guard byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9") else {
        return nil // Return nil for invalid characters.
      }

      // Convert the ASCII byte to an integer and add it to the result.
      result = result * 10 + Int(byte - UInt8(ascii: "0"))
      index += 1
    }

    // Apply the negative sign if the number was marked as negative.
    result = isNegative ? -result : result

    // Validate
    if let min, result < min { return nil }
    if let max, result > max { return nil }

    return result
  }

  /// Parses a comma-separated list from a buffer slice and transforms each element using the provided closure.
  /// This function splits the buffer slice into individual elements, separated by commas (`','`), and applies the
  /// `transform` closure to each element to parse or process it. If any element fails to transform, the function
  /// returns `nil`.
  ///
  /// - Parameters:
  ///   - bufferSlice: A slice of an `UnsafeBufferPointer<UInt8>` containing the raw UTF-8 data to parse.
  ///   - transform: A closure that takes a slice of the buffer and transforms it into the desired type `T`.
  ///     If the transformation fails, the closure should return `nil`.
  ///
  /// - Returns: An array of transformed elements of type `T`, or `nil` if any element fails to transform.
  private func parseAsList<T>(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>, transform: (Slice<UnsafeBufferPointer<UInt8>>) -> T?) -> [T]? {
    var results: [T] = []
    var index = bufferSlice.startIndex // Current position in the buffer
    var start = index // Start of the current element

    while index <= bufferSlice.endIndex {
      // If we reach a comma or the end of the slice
      if index == bufferSlice.endIndex || bufferSlice[index] == UInt8(ascii: ",") {
        guard let element = transform(bufferSlice[start..<index]) else {
          return nil // If the transformation fails, return nil for the whole list
        }

        results.append(element)
        start = index + 1 // Move to the start of the next number
      }

      index += 1
    }

    return results.isEmpty ? nil : results
  }

  /// Parses a buffer slice as a `RecurrenceRule.Frequency`.
  /// This function compares the slice of raw UTF-8 data with predefined frequency values
  /// ("MINUTELY", "HOURLY", "DAILY", "WEEKLY", "MONTHLY", "YEARLY") and returns the corresponding
  /// `RecurrenceRule.Frequency` enum value.
  ///
  /// - Parameter bufferSlice: A slice of an `UnsafeBufferPointer<UInt8>` containing the raw data to parse.
  /// - Returns: A `RecurrenceRule.Frequency` if the slice matches a known frequency, otherwise `nil`.
  ///
  /// - Warning: The "SECONDLY" frequency is currently not supported in `RecurrenceRule.Frequency`.
  private func parseAsFrequency(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>) -> RecurrenceRule.Frequency? {
    switch bufferSlice.count {
    case 8 where bufferSlice.elementsEqual("MINUTELY".utf8): .minutely
    case 6 where bufferSlice.elementsEqual("HOURLY".utf8): .hourly
    case 5 where bufferSlice.elementsEqual("DAILY".utf8): .daily
    case 6 where bufferSlice.elementsEqual("WEEKLY".utf8): .weekly
    case 7 where bufferSlice.elementsEqual("MONTHLY".utf8): .monthly
    case 6 where bufferSlice.elementsEqual("YEARLY".utf8): .yearly
    default: nil
    }
  }

  /// Parses a slice of a buffer as a `Date` object.
  /// This function converts a slice of raw UTF-8 data representing a date or date-time
  /// into a `Date` object. It supports the following formats:
  /// - Local date-time with time zone: `TZID=America/New_York:19970714T133000`
  /// - UTC date-time: `19970714T173000Z`
  /// - Local date-time: `19970714T133000`
  /// - Local date: `19970714`
  ///
  /// - Parameter bufferSlice: A slice of an `UnsafeBufferPointer<UInt8>` containing the raw data to parse.
  /// - Returns: A `Date` object if the parsing is successful, otherwise `nil`.
  private func parseAsDate(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>) -> Date? {
    var timeZone: TimeZone? = nil
    var dateSlice = bufferSlice

    /// Helper function to parse date components from a slice.
    /// - Parameters:
    ///   - bufferSlice: The slice containing the date or date-time data.
    ///   - timeZone: The time zone to apply to the components.
    /// - Returns: A `DateComponents` object if the parsing is successful, otherwise `nil`.
    func parseDateComponets(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>, tz timeZone: TimeZone? = nil) -> DateComponents? {
      guard bufferSlice.count > 0 else { return nil }

      if bufferSlice.count == 8 { // DATE
        let year = parseAsInt(bufferSlice[bufferSlice.startIndex..<bufferSlice.startIndex + 4])
        let month = parseAsInt(bufferSlice[bufferSlice.startIndex + 4..<bufferSlice.startIndex + 6], min: 1, max: 12)
        let day = parseAsInt(bufferSlice[bufferSlice.startIndex + 6..<bufferSlice.startIndex + 8], min: 1, max: 31)

        guard let year, let month, let day else {
          return nil
        }

        var components = DateComponents(year: year, month: month, day: day)
        components.timeZone = timeZone
        return components
      }

      if bufferSlice.count == 15 { // DATE-TIME
        let year = parseAsInt(bufferSlice[bufferSlice.startIndex..<bufferSlice.startIndex + 4])
        let month = parseAsInt(bufferSlice[bufferSlice.startIndex + 4..<bufferSlice.startIndex + 6], min: 1, max: 12)
        let day = parseAsInt(bufferSlice[bufferSlice.startIndex + 6..<bufferSlice.startIndex + 8], min: 1, max: 31)
        let hour = parseAsInt(bufferSlice[bufferSlice.startIndex + 9..<bufferSlice.startIndex + 11], min: 1, max: 24)
        let minute = parseAsInt(bufferSlice[bufferSlice.startIndex + 11..<bufferSlice.startIndex + 13], min: 0, max: 59)
        let second = parseAsInt(bufferSlice[bufferSlice.startIndex + 13..<bufferSlice.startIndex + 15], min: 0, max: 60)

        guard let year, let month, let day, let hour, let minute, let second else {
          return nil
        }

        var components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        components.timeZone = timeZone

        return components
      }

      return nil
    }

    // Local time and time zone reference
    // e.g. "TZID=America/New_York:19970714T133000"
    if let tzidEnd = bufferSlice.firstIndex(of: 58), bufferSlice.prefix(upTo: tzidEnd).contains(61) { // Contains 'TZID='
      let tzidStart = bufferSlice.firstIndex(of: 61)! + 1
      let tzidSlice = bufferSlice[tzidStart..<tzidEnd]
      dateSlice = bufferSlice[(tzidEnd + 1)...]

      guard let timeZoneName = String(bytes: tzidSlice, encoding: .utf8),
            let tz = TimeZone(identifier: timeZoneName) else {
        return nil
      }
      timeZone = tz
    } else if bufferSlice.count == 16 && bufferSlice.last == UInt8(ascii: "Z") {
      timeZone = .gmt
      dateSlice = bufferSlice.dropLast() // Remove 'Z'
    }

    // Parse common date components
    guard let dateComponents = parseDateComponets(dateSlice, tz: timeZone) else {
      return nil
    }

    return calendar.date(from: dateComponents)
  }

  /// Parses a buffer slice into a `RecurrenceRule.Weekday` according to RFC 5545.
  ///
  /// This function checks if the input slice represents a valid weekday in the `BYDAY` format
  /// as defined in RFC 5545. The input can optionally include an ordinal number (e.g., `-1MO`, `2TU`)
  /// or just a weekday abbreviation (`MO`, `TU`, etc.).
  ///
  /// - Parameter bufferSlice: A slice of an `UnsafeBufferPointer<UInt8>` containing the raw data to parse.
  /// - Returns: A `RecurrenceRule.Weekday` if the slice is valid, otherwise `nil`.
  ///
  /// ## Format:
  /// `BYDAY` specifies days of the week with an optional ordinal number.
  ///  Example: `-1MO` (last Monday of the month), `2TU` (second Tuesday), `WE` (every Wednesday).
  ///
  /// ## Examples:
  ///   - `MO` -> `.every(.monday)`
  ///   - `-1SU` -> `.nth(-1, .sunday)`
  ///   - `2FR` -> `.nth(2, .friday)`
  ///
  /// - Note: Only two-character abbreviations are supported for weekdays (`MO`, `TU`, etc.).
  private func parseAsWeekday(_ bufferSlice: Slice<UnsafeBufferPointer<UInt8>>) -> RecurrenceRule.Weekday? {
    var ordinal: Int?
    var index = bufferSlice.startIndex

    // Check if the weekday slice starts with a possible ordinal (e.g., -1, 1, 2, etc.)
    if bufferSlice[index] == UInt8(ascii: "-") || (bufferSlice[index] >= UInt8(ascii: "0") && bufferSlice[index] <= UInt8(ascii: "9")) {
      let digitsRange = UInt8(ascii: "0")...UInt8(ascii: "9")
      let ordinalEnd = bufferSlice[index...].firstIndex(where: { !digitsRange.contains($0) && $0 != UInt8(ascii: "-") }) ?? bufferSlice.endIndex
      let ordinalSlice = bufferSlice[index..<ordinalEnd]

      // Parse the ordinal value
      guard let ordinalValue = parseAsInt(ordinalSlice) else {
        return nil
      }

      ordinal = ordinalValue
      index = ordinalEnd // Move index past the ordinal number
    }

    // Remaining part should match a weekday abbreviation (e.g., MO, TU, WE, etc.)
    let weekdaySlice = bufferSlice[index..<bufferSlice.endIndex]
    guard weekdaySlice.count == 2 else {
      return nil
    }

    // Map the abbreviation to a Locale.Weekday
    let weekday: Locale.Weekday
    switch weekdaySlice {
    case let slice where slice.elementsEqual("MO".utf8): weekday = .monday
    case let slice where slice.elementsEqual("TU".utf8): weekday = .tuesday
    case let slice where slice.elementsEqual("WE".utf8): weekday = .wednesday
    case let slice where slice.elementsEqual("TH".utf8): weekday = .thursday
    case let slice where slice.elementsEqual("FR".utf8): weekday = .friday
    case let slice where slice.elementsEqual("SA".utf8): weekday = .saturday
    case let slice where slice.elementsEqual("SU".utf8): weekday = .sunday
    default: return nil
    }

    guard let ordinal else {
      return .every(weekday)
    }

    return .nth(ordinal, weekday)
  }

  private func parseError(_ value: String, exampleFormattedString: String?) -> CocoaError {
    let errStr: String
    if let exampleFormattedString {
      errStr = "Cannot parse \(value). String should adhere to the preferred format of the locale, such as \(exampleFormattedString)."
    } else {
      errStr = "Cannot parse \(value)."
    }

    return CocoaError(CocoaError.formatting, userInfo: [NSDebugDescriptionErrorKey: errStr])
  }
}
