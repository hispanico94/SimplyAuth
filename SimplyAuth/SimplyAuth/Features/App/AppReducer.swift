//
//  AppReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 17/08/2020.
//

import ComposableArchitecture
import Foundation

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .addPassword(let password):
    state.passwords.append(password)
    let newIds = state.passwords.map(\.id)
    
    return .fireAndForget {
      environment.idStore.saveIds(newIds)
      try? environment.passwordStore.savePassword(password)
    }
    
  case .ids(let ids):
    return environment.passwordStore
      .getPasswords(ids)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .catchToEffect()
      .map(AppAction.passwords)
    
  case .onAppear:
    return environment.idStore
      .getIds()
      .map(AppAction.ids)
      .eraseToEffect()
    
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
    
  case .updateCounter(var password):
    guard
      case .counterBased(var hotpPass) = password.typology
    else { return .none }
    
    hotpPass.counter += 1
    password.typology = .counterBased(hotpPass)
    
    return .fireAndForget {
      try? environment.passwordStore.savePassword(password)
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
