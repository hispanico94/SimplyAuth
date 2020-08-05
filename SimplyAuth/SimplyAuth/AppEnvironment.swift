//
//  AppEnvironment.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import ComposableArchitecture
import Foundation

struct AppEnvironment {
  var date: () -> Date
  var uuid: () -> UUID
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var idStore: IDStore
  var passwordStore: PasswordStore
}
