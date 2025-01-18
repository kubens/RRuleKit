# RRuleKit

RRuleKit is a Swift library for parsing and formatting recurrence rules defined in the [RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10) specification. The package is designed for high performance and low memory overhead, utilizing Swift’s powerful type system and `UnsafeBufferPointer` for optimized parsing.

---

## Features

This library provides comprehensive support for parsing and formatting recurrence rules defined by the [RFC 5545 iCalendar specification](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10).

### Mandatory Rule Parts

- `FREQ`: Specifies the frequency of the recurrence (e.g., `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY`, etc.).  
    *Supported values:* `MINUTELY`, `HOURLY`, `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY`.

### Optional Rule Parts:

- `COUNT`: Specifies the number of occurrences in the recurrence.
- `UNTIL`: Defines the end date of the recurrence in either UTC or local time. Includes support for:
  - **UTC time**: e.g., `UNTIL=20250118T102600Z`.
  - **Local time with TZID**: e.g., `UNTIL=TZID=America/New_York:20250118T102200`.
  - **Local date**: e.g., `UNTIL=20250118`.

- `INTERVAL`: Specifies the interval between occurrences. Defaults to `1` if not explicitly defined.

- `BYSECOND`: Defines specific seconds within a minute for the recurrence (e.g., `BYSECOND=0,15,30`).
- `BYMINUTE`: Defines specific minutes within an hour for the recurrence (e.g., `BYMINUTE=0,15,30`).
- `BYHOUR`: Defines specific hours within a day for the recurrence (e.g., `BYHOUR=8,12,16`).
- `BYDAY`: Defines specific days of the week for the recurrence.  
  Example values:
  - `BYDAY=MO,TU`: Every Monday and Tuesday.
  - `BYDAY=1SU`: The first Sunday of the month.
  - `BYDAY=-1FR`: The last Friday of the month.

- `BYMONTHDAY`: Specifies particular days of the month (e.g., `BYMONTHDAY=1,15,31`).
- `BYYEARDAY`: Specifies particular days of the year (e.g., `BYYEARDAY=1,100,365`).
- `BYWEEKNO`: Specifies particular weeks of the year (e.g., `BYWEEKNO=1,10,52`).
- `BYMONTH`: Specifies particular months of the year (e.g., `BYMONTH=1,6,12`).
- `BYSETPOS`: Filters occurrences by their position within the set of recurrence instances.  
  Example values:
  - `BYSETPOS=1`: The first instance.
  - `BYSETPOS=-1`: The last instance.

**Robust Parsing and Formatting**:
  - Automatically handles valid and invalid rule part combinations, including:
    - Ensuring that `COUNT` and `UNTIL` are not used together.
    - Validating ranges for numerical values (e.g., seconds, minutes, days).
  - Converts between `Calendar.RecurrenceRule` objects and RFC 5545-compliant strings.

---

## Platform Support

`RRuleKit` is compatible with the following platforms:

- **iOS**: v18 or later
- **macOS**: v15 or later
- **Mac Catalyst**: v18 or later
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
    print("Months: \(recurrenceRule.months)")
    print("Weekdays: \(recurrenceRule.weekdays)")
} catch {
    print("Failed to parse the recurrence rule: \(error)")
}
```

### Formatting a Recurrence Rule to String

Use the same `RecurrenceRuleRFC5545FormatStyle` to format a `Calendar.RecurrenceRule` object back into an RFC 5545-compliant string.

#### Example

```swift
let formatter = RecurrenceRuleRFC5545FormatStyle(calendar: .current)
let rrule = Calendar.RecurrenceRule(
    calendar: .current,
    frequency: .daily,
    interval: 2,
    end: .afterOccurrences(5),
    weekdays: [.every(.monday), .every(.wednesday)]
)
let result = formatter.format(rrule)
print(result) // Outputs: "FREQ=DAILY;INTERVAL=2;COUNT=5;BYDAY=MO,WE"
```

---

## Calendar.RecurrenceRule.End Support

The library includes support for the `.afterOccurrences` and `.afterDate` formats within `Calendar.RecurrenceRule.End`. However, these formats are available only on the following platform versions:

- **iOS**: v18.2 or later
- **macOS**: v15.2 or later
- **Mac Catalyst**: v18.2 or later
- **tvOS**: v18.2 or later
- **watchOS**: v11.2 or later
- **visionOS**: v2.2 or later

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

## Testing

`RRuleKit` includes an extensive test suite that validates the following:

- Correct parsing and formatting of all supported rule parts.
- Compliance with the RFC 5545 standard.
- Buffer capacity adjustments to handle large RRULE strings efficiently.

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