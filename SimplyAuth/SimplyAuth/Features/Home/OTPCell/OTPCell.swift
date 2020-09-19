//
//  OTPCell.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 12/09/2020.
//

import Foundation

enum OTPCell: Equatable, Identifiable {
  case hotp(HOTPCell)
  case totp(TOTPCell)
  
  var id: UUID {
    switch self {
    case .hotp(let cell):
      return cell.id
    case .totp(let cell):
      return cell.id
    }
  }
}

struct HOTPCell: Equatable, Identifiable {
  var id: UUID
  var issuer: String
  var label: String
  var currentPassword: String
}

struct TOTPCell: Equatable, Identifiable {
  var id: UUID
  var issuer: String
  var label: String
  var currentPassword: String
  var timeLeft: String
}
