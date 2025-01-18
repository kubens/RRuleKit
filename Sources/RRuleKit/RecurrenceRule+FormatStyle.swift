//
//  RecurrenceRule+FormatStyle.swift
//  RRuleKit
//
//  Created by kubens.com on 14/01/2025.
//

import Foundation

extension Calendar.RecurrenceRule {

  public init<T: ParseStrategy>(_ value: T.ParseInput, strategy: T) throws where T.ParseOutput == Self {
    self = try strategy.parse(value)
  }

  public func formatted<F: FormatStyle>(_ format: F) -> F.FormatOutput where F.FormatInput == Self {
    format.format(self)
  }
}
