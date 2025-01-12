# RRuleKit

RRuleKit is a Swift library for parsing and formatting recurrence rules defined in the [RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10) specification. The package is designed for high performance and low memory overhead, utilizing Swift’s powerful type system and UnsafeBufferPointer for optimized parsing.

---

## Features

- Parses recurrence rules (`RRULE`) from strings into Foundation `Calendar.RecurrenceRule` objects.
- Supports the following `RRULE` components:
  - **FREQ**: Defines the recurrence frequency. *(Mandatory key)*.
  - **UNTIL**: Specifies the end date of the recurrence.
  - **COUNT**: Specifies the number of occurrences.
  - **INTERVAL**: Specifies the interval between occurrences (default is `1`).
  - **BY* Keys**:
    - `BYSECOND`, `BYMINUTE`, `BYHOUR`, `BYDAY`, `BYMONTHDAY`, `BYYEARDAY`, `BYWEEKNO`, `BYMONTH`, `BYSETPOS`.
- Fully compliant with the RFC 5545 specification for supported keys and formats.
- Performs value range validation for components like `BY*` keys and `COUNT`.
- Leverages Swift concurrency (`Sendable`) for thread safety.

---

## Platform Support

`RRuleKit` is compatible with the following platforms:

- **iOS**: v18 or later
- **macOS**: v15 or later
- **Mac Catalyst**: v15 or later
- **tvOS**: v18 or later
- **watchOS**: v11 or later
- **visionOS**: v2 or later

### Notes
`RRuleKit` is based on `Foundation.Calendar.RecurrenceRule`, which was introduced in Swift Foundation as part of [swift-foundation PR #464](https://github.com/swiftlang/swift-foundation/pull/464). Due to this dependency, `RRuleKit` supports only platforms where `Calendar.RecurrenceRule` is available.

---

## Usage

### Parsing an RFC 5545 Recurrence Rule String

You can use `RecurrenceRuleRFC5545FormatStyle` to parse RFC 5545-compliant recurrence rule strings into `Calendar.RecurrenceRule` instances.

#### Example

```swift
import Foundation
import RRuleKit

// Initialize the parser with the desired calendar (optional)
let parser = RecurrenceRuleRFC5545FormatStyle(calendar: .current)

do {
    let rfcString = "FREQ=MONTHLY;BYDAY=MO,TU;BYMONTH=1,6;COUNT=5"
    let recurrenceRule = try parser.parse(rfcString)

    print("Frequency: \(recurrenceRule.frequency)")
    print("End: \(recurrenceRule.end)")
    print("Months: \(recurrenceRule.months ?? [])")
    print("Weekdays: \(recurrenceRule.weekdays ?? [])")
} catch {
    print("Failed to parse the recurrence rule: \(error)")
}
```

---

## Key RFC 5545 Parsing Rules

 - **FREQ** is mandatory and must be the first key in the rule string.
 - Currently, FREQ=SECONDLY is not supported.
 - Only one of COUNT or UNTIL can be specified.
 - Keys and values are separated by = and must be delimited by ;.
 - Value ranges are validated based on the key:
    
    - `BYSECOND` 0-60
    - `BYMINUTE` 0-59
    - `BYHOUR` 0-23
    - `BYMONTH` 1-12
    - `BYDAY` Specifies weekdays with optional ordinal modifiers (e.g., -1MO, 2TU)
    - `BYMONTHDAY` -31 to 31
    - `BYYEARDAY` -366 to 366
    - `BYWEEKNO` -53 to 53
    - `BYSETPOS` -366 to 366

### Validation

The library enforces strict validation for each key, ensuring values fall within the valid ranges specified by the RFC 5545 standard. 

For example:

- `BYSECOND` values must be in the range 0–60.
- `BYMONTHDAY` values must be in the range -31–31.
- `UNTIL` and `COUNT` cannot coexist in the same rule.

### Limitations

`FREQ=SECONDLY` is not supported because `Calendar.RecurrenceRule.Frequency` does not currently include this frequency. If the input string specifies `FREQ=SECONDLY`, the library will throw an error.

---

## Installation

### Swift Package Manager (SPM)

Add the following dependency to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/kubens/RRuleKit", from: "1.0.0")
]
```

Then, add RRuleKit to your target’s dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["RRuleKit"]
)
```

## License

`RRuleKit` is released under the MIT License. See the [LICENSE](./LICENSE) file for more details.

## References

- **RFC 5545: Internet Calendaring and Scheduling Core Object Specification (iCalendar)**  
  The full specification can be found at [RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545).

- **Swift Foundation Calendar.RecurrenceRule**  
  `RecurrenceRule` is part of the Swift Foundation and provides a Swift-native way to define recurrence rules. [Apple Developer Documentation - Calendar.RecurrenceRule](https://developer.apple.com/documentation/foundation/calendar/recurrencerule)
  See the [Swift Foundation pull request #464](https://github.com/swiftlang/swift-foundation/pull/464) for details.