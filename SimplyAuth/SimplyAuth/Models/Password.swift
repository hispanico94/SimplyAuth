//
//  Password.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 02/08/2020.
//

import Foundation

struct Password {
  enum Typology {
    case counterBased(HOTP)
    case timeBased(TOTP)
  }
  
  var id: UUID = UUID()
  var isFromQRCode: Bool = false
  var typology: Typology
}
