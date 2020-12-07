//
//  ScannerReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/10/2020.
//

import ComposableArchitecture
import Foundation

let scannerReducer = editReducer
  .optional()
  .pullback(
    state: \ScannerState.optionalEditState,
    action: /ScannerAction.edit,
    environment: { _ in }
  )
  .combined(with: _scannerReducer)

private let _scannerReducer = Reducer<ScannerState, ScannerAction, ScannerEnvironment> { state, action, environment in
  switch action {
  case .dismissButtonTapped:
    return .none
    
  case .errorAlertDismissed:
    state.errorAlertMessage = nil
    state.qrCodeString = nil
    return .none
    
  case .manualEntryButtonTapped:
    state.password = Password(secret: "", issuer: "", label: "")
    return .none
    
  case .passwordCreated:
    return .none
    
  case .qrCodeFound(let qrCode):
    if let newPassword = qrCode.flatMap(Password.init(string:)) {
      state.password = newPassword
      return .fireAndForget {
        environment.feedback.successFeedback()
      }
    }
    state.qrCodeString = qrCode
    state.errorAlertMessage = "Failed to read QR code"
    return .fireAndForget {
      environment.feedback.errorFeedback()
    }
  
  case .edit(.save):
    guard let newPassword = state.password else { return .none }
    return .init(value: .passwordCreated(newPassword))
    
  case .edit:
    return .none
    
  case .setEditNavigation(false):
    state.password = nil
    return .none
    
  case .setEditNavigation(true):
    return .none
  }
}
