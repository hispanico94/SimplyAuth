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
  var feedback: FeedbackGenerator
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var idStore: IDStore
  var passwordStore: PasswordStore
}

// MARK: Live implementation

extension HomeEnvironment {
  static let live = HomeEnvironment(
    date: Date.init,
    uuid: UUID.init,
    clipboard: { otp in UIPasteboard.general.string = otp },
    feedback: .live,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    idStore: .live,
    passwordStore: .live
  )
}

// MARK: Mock implementation

extension HomeEnvironment {
  static let mock = HomeEnvironment(
    date: { Date(timeIntervalSince1970: 1601200819) },
    uuid: UUID.init,
    clipboard: { otp in UIPasteboard.general.string = otp },
    feedback: .liveDebug,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    idStore: .mock,
    passwordStore: .mock
  )
}

extension HomeEnvironment {
  static let mockDateLive = HomeEnvironment(
    date: Date.init,
    uuid: UUID.init,
    clipboard: { otp in UIPasteboard.general.string = otp },
    feedback: .liveDebug,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    idStore: .mock,
    passwordStore: .mock
  )
}
