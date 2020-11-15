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
    
  case .errorAlertDismissed:
    state.errorAlertMessage = nil
    state.qrCodeString = nil
    return .none
    
  case .manualEntryButtonTapped:
    return .none
    
  case .passwordFound:
    return .none
    
  case .qrCodeFound(let qrCode):
    state.qrCodeString = qrCode
    if let newPassword = qrCode.flatMap(Password.init(string:)) {
      return Effect(value: .passwordFound(newPassword))
    }
    state.errorAlertMessage = "Failed to read QR code"
    return .none
  }
}
