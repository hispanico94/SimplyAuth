//
//  ScannerReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/10/2020.
//

import ComposableArchitecture
import Foundation

let scannerReducer = Reducer<ScannerState, ScannerAction, Void> { state, action, _ in
  switch action {
  case .dismissButtonTapped:
    return .none
  case .manualEntryButtonTapped:
    return .none
  case .qrCodeFound(let qrCode):
    state.qrCode = qrCode
    return .none
  }
}
