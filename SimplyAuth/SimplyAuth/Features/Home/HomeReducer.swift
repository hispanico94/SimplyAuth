//
//  HomeReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 11/09/2020.
//

import ComposableArchitecture
import Foundation

let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, environment in
  struct ClockTimerID: Hashable { }
  
  switch action {
  case .addPassword(let password):
    state.passwords.append(password)
    let newIds = state.passwords.map(\.id)
    
    return .fireAndForget {
      environment.idStore.saveIds(newIds)
      try? environment.passwordStore.savePassword(password)
    }
    
  case .clockTick(let secondsSince1970):
    state.unixEpochSeconds = secondsSince1970
    return .none
    
  case .ids(let ids):
    return environment.passwordStore
      .getPasswords(ids)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .catchToEffect()
      .map(HomeAction.passwords)
    
  case .onAppear:
    let secondOffset = environment.date()
      .timeIntervalSince1970
      .truncatingRemainder(dividingBy: 1)
    
    return .merge (
      environment.idStore
        .getIds()
        .map(HomeAction.ids)
        .eraseToEffect(),
      Effect(value: ())
        .delay(for: .seconds(1 - secondOffset), tolerance: .milliseconds(10), scheduler: environment.mainQueue)
        .flatMap { _ in Effect.timer(id: ClockTimerID(), every: 1, tolerance: .milliseconds(10), on: environment.mainQueue) }
        .map { _ in environment.date().timeIntervalSince1970 }
        .map(UInt.init)
        .map(HomeAction.clockTick)
        .eraseToEffect()
    )
    
  case .onDisappear:
    return .cancel(id: ClockTimerID())
    
  case .password(var password, .updateCounter):
    guard
      case .hotp(var counter) = password.typology
    else { return .none }
    
    counter += 1
    password.typology = .hotp(counter)
    
    return .fireAndForget {
      try? environment.passwordStore.savePassword(password)
    }
    
  case .passwords(.success(let passwords)):
    state.passwords = passwords
    return .none
    
  case .removePassword(let password):
    state.passwords.removeAll { $0.id == password.id }
    return .fireAndForget {
      try? environment.passwordStore.removePassword(password)
    }
    
  case .reorder(let source, let destination):
    state.passwords.move(fromOffsets: source, toOffset: destination)
    let newIds = state.passwords.map(\.id)
    
    return .fireAndForget {
      environment.idStore.saveIds(newIds)
    }
    
  case .updatePassword(let password):
    return .fireAndForget {
      try? environment.passwordStore.savePassword(password)
    }
    
  case .passwords(.failure(let error)):
    print("FAILURE RETURNING PASSWORDS: \(error)")
    return .none
  }
}
