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
  var unixEpochSeconds: UInt = 0
  
  var optionalScanner: ScannerState?
  
  var passwordToEdit: Password?
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
          return .totp(TOTPCell(
            id: password.id,
            issuer: password.issuer,
            label: password.label,
            currentPassword: OTPExtractor.totpCode(from: password, unixEpochSeconds: unixEpochSeconds) ?? "ERROR",
            timeLeft: "\(interval - (unixEpochSeconds % interval))",
            percentTimeLeft: 100 * (Double(interval) - Double(unixEpochSeconds % interval)) / Double(interval)
          ))
        }
      })
  }
  
  var isEditNavigationActive: Bool { optionalEdit != nil }
  var isScannerPresented: Bool { optionalScanner != nil }
}
