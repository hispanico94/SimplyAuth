//
//  ScannerState.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/10/2020.
//

import Foundation

struct ScannerState: Equatable {
  var qrCodeString: String? = nil
  var errorAlertMessage: String? = nil
  var password: Password? = nil
  
  var isEditNavigationActive: Bool { optionalEditState != nil }
  
  var optionalEditState: EditState? {
    get {
      password.map { EditState(isNewPassword: true, password: $0) }
    }
    set {
      password = newValue?.password
    }
  }
}
