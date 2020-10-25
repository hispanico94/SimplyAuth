//
//  Extensions.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 23/09/2020.
//

import UIKit

// MARK: - String Interpolation

extension String.StringInterpolation {
  mutating func appendInterpolation(value: CGFloat, using formatter: NumberFormatter) {
    if let result = formatter.string(for: value) {
      appendLiteral(result)
    }
  }
}

// MARK: - Number Formatter

extension NumberFormatter {
  static let noDecimalsFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 0
    return f
  }()
}

// MARK: - UUID

extension UUID {
  static let allZeros = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

// MARK: - UInt8

extension UInt8: Identifiable {
  public var id: UInt8 { self }
}
