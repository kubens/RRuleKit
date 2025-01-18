# Parsing RFC 5545 Strings

This document details how to parse RFC 5545-compliant recurrence rule strings using `RecurrenceRuleRFC5545FormatStyle`.

## Overview

Parsing functionality allows conversion of strings like:

```plaintext
FREQ=WEEKLY;BYDAY=MO,WE,FR;INTERVAL=2;COUNT=10
```

into structured `Calendar.RecurrenceRule objects`.

## Example

```swift
import Foundation
import RRuleKit

let parser = RecurrenceRuleRFC5545FormatStyle(calendar: .current)

do {
let rfcString = "FREQ=WEEKLY;BYDAY=MO,WE,FR;INTERVAL=2;COUNT=10"
let recurrenceRule = try parser.parse(rfcString)
  print(recurrenceRule)
} catch {
  print("Parsing error: \(error)")
}
```

## Notes

- FREQ is mandatory and must appear first.
- COUNT and UNTIL cannot coexist in a rule.
- Invalid or unsupported keys will cause parsing to fail.
