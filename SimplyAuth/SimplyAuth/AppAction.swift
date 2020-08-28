//
//  AppAction.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import Foundation

enum AppAction {
  case addPassword(Password)
  case ids([UUID])
  case onAppear
  case passwords(Result<[Password], PasswordStore.Error>)
  case removePassword(Password)
  case reorder(source: IndexSet, destination: Int)
  case updateCounter(Password)
  case updatePassword(Password)
}
