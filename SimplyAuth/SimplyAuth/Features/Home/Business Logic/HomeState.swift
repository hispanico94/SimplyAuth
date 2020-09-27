//
//  HomeState.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 04/09/2020.
//

import Foundation

struct HomeState: Equatable {
  var passwords: [Password] = []
  var unixEpochSeconds: UInt = 0
  
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
            timeLeft: "\(unixEpochSeconds % interval)",
            percentTimeLeft: 100 * Double(unixEpochSeconds % interval) / Double(interval)
          ))
        }
      })
  }
}
