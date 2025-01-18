# ``RRuleKit``

RRuleKit is a Swift library for parsing and formatting recurrence rules defined in the `RFC 5545` specification. The package is designed for high performance and low memory overhead, utilizing Swift’s powerful type system and `UnsafeBufferPointer` for optimized parsing. 


## Overview

`RecurrenceRuleRFC5545FormatStyle` is a Swift-native utility for handling recurrence rules based on the [RFC 5545 specification](https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10). It supports:

- Parsing RFC 5545-compliant strings into `Calendar.RecurrenceRule` objects.
- Formatting `Calendar.RecurrenceRule` objects back into RFC 5545 strings.

Each feature is optimized for performance and adheres to the rules and constraints of the standard.

---

## Features

- **Parsing**: Converts RFC 5545 strings into recurrence rule objects while validating constraints.
- **Formatting**: Generates RFC 5545-compliant strings from recurrence rule objects.
- **Support for rule parts**:
  - `FREQ`
  - `COUNT`
  - `UNTIL`
  - `INTERVAL`
  - `BYSECOND`
  - `BYMINUTE`
  - `BYHOUR`
  - `BYDAY`
  - `BYMONTHDAY`
  - `BYYEARDAY`
  - `BYWEEKNO` 
  - `BYMONTH` 
  - `BYSETPOS`

- **Time Zone Handling**:
  - Supports both UTC and local time zone representations.
  - Includes `TZID` for local times.

## Topics

### Essentials

- <doc:ParsingRFC5545>
- <doc:FormattingRFC5545>

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->

## See Also

- [RFC 5545: Internet Calendaring and Scheduling Core Object Specification](https://datatracker.ietf.org/doc/html/rfc5545)
- [Swift Foundation PR #464](https://github.com/swiftlang/swift-foundation/pull/464)
