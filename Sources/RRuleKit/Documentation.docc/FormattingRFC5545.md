# Formatting to RFC 5545 Strings

This document details how to format `Calendar.RecurrenceRule` objects into RFC 5545-compliant strings.

## Overview

Formatting functionality allows conversion of recurrence rule objects like:

```swift
let rrule = Calendar.RecurrenceRule(
  calendar: .current,
  frequency: .monthly,
  interval: 1,
  end: .afterOccurrences(5),
  weekdays: [.every(.monday), .every(.wednesday)]
)
```

into strings like:

```plaintext
FREQ=MONTHLY;INTERVAL=1;COUNT=5;BYDAY=MO,WE
```

## Example

```swift
import Foundation
import RRuleKit

let formatter = RecurrenceRuleRFC5545FormatStyle(calendar: .current)

let rrule = Calendar.RecurrenceRule(
  calendar: .current,
  frequency: .weekly,
  interval: 1,
  weekdays: [.every(.monday), .every(.friday)]
)

let rfcString = formatter.format(rrule)
print(rfcString)
// Output: "FREQ=WEEKLY;BYDAY=MO,FR"
```
