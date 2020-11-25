//
//  HomeAction.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 10/09/2020.
//

import Foundation

enum HomeAction {
  case addPassword(Password)
  case clockTick(secondsSince1970: UInt)
  case edit(EditAction)
  case ids([UUID])
  case onAppear
  case onDisappear
  case password(id: UUID, action: PasswordAction)
  case passwords(Result<[Password], PasswordStore.Error>)
  case reorder(source: IndexSet, destination: Int)
  case scanner(ScannerAction)
  case setEditNavigation(isActive: Bool)
  case setScannerSheet(isPresented: Bool)
  case updatePassword(Password)
}

enum PasswordAction {
  case copyToClipboard
  case delete
  case edit
  case updateCounter
}

