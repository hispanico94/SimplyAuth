//
//  ScannerEnvironment.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 04/12/2020.
//

import Foundation

struct ScannerEnvironment {
  var feedback: FeedbackGenerator
}

// MARK: Live implementation

extension ScannerEnvironment {
  static let live = ScannerEnvironment(
    feedback: .live
  )
}
