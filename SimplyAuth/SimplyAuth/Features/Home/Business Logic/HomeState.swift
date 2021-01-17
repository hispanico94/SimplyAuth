//
//  HomeState.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 04/09/2020.
//

import Foundation

struct HomeState: Equatable {
  var firstAppearance: Bool = true
  var passwords: [Password] = []
  var unixEpochSeconds: UInt64 = 0
  
  var message: String? = nil
  
  var optionalScanner: ScannerState? = nil
  
  var passwordToEdit: Password? = nil
}

// MARK: - Computed properties

extension HomeState {
  var optionalEdit: EditState? {
    get {
      passwordToEdit.map { EditState(isNewPassword: false, password: $0) }
    }
    set {
      passwordToEdit = newValue?.password
    }
  }
  
  var cells: [OTPCell] {
    passwords
      .map({ password in
        switch password.typology {
        case .hotp:
          return .hotp(HOTPCell(
            id: password.id,
            issuer: password.issuer,
            label: password.label,
            currentPassword: OTPExtractor.hotpCode(from: password) ?? "ERROR"
          ))
        case .totp(let interval):
          let secondsLeft = interval - (unixEpochSeconds % interval)
          
          return .totp(TOTPCell(
            id: password.id,
            issuer: password.issuer,
            label: password.label,
            currentPassword: OTPExtractor.totpCode(from: password, unixEpochSeconds: unixEpochSeconds) ?? "ERROR",
            timeLeft: "\(secondsLeft)",
            percentTimeLeft: 100 * Double(secondsLeft) / Double(interval),
            timeRemainingLow: secondsLeft <= 6
          ))
        }
      })
  }
  
  var isEditNavigationActive: Bool { optionalEdit != nil }
  var isScannerPresented: Bool { optionalScanner != nil }
  var isMessageShown: Bool { message != nil }
}
