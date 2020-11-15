//
//  ScannerAction.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/10/2020.
//

import Foundation

enum ScannerAction {
  case dismissButtonTapped
  case errorAlertDismissed
  case manualEntryButtonTapped
  case passwordCreated(Password)
  case qrCodeFound(String?)
  case edit(EditAction)
  case setEditNavigation(isActive: Bool)
}
