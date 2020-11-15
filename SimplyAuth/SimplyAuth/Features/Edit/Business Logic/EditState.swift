//
//  EditState.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 21/10/2020.
//

import Foundation

struct EditState: Equatable {
  let algorithms: [Algorithm] = [.sha1, .sha256, .sha512]
  let digits: [UInt8] = [6, 7, 8]
  let passwordTypologies: [Password.Typology] = [.hotp(0), .totp(30)]
  
  var isNewPassword: Bool
  var password: Password
}
