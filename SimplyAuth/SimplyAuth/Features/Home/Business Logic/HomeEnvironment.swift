//
//  HomeEnvironment.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 11/09/2020.
//

import ComposableArchitecture
import MobileCoreServices
import UIKit

struct HomeEnvironment {
  var date: () -> Date
  var uuid: () -> UUID
  var clipboard: (String) -> ()
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var idStore: IDStore
  var passwordStore: PasswordStore
}

// MARK: Mock implementation

extension HomeEnvironment {
  static let mock = HomeEnvironment(
    date: { Date(timeIntervalSince1970: 1601200819) },
    uuid: UUID.init,
    clipboard: { otp in UIPasteboard.general.string = otp },
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    idStore: .mock,
    passwordStore: .mock
  )
}
