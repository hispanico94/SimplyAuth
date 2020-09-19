//
//  HomeEnvironment.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 11/09/2020.
//

import ComposableArchitecture
import Foundation

struct HomeEnvironment {
  var date: () -> Date
  var uuid: () -> UUID
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var idStore: IDStore
  var passwordStore: PasswordStore
}
