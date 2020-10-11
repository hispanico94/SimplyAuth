//
//  HomeReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 11/09/2020.
//

import ComposableArchitecture
import Foundation

let homeReducer = Reducer.combine(
  scannerReducer
    .pullback(
      state: \HomeState.scanner,
      action: /HomeAction.scanner,
      environment: { _ in }
    ),
  _homeReducer
)


private let _homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, environment in
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
    
  case .password(let id, action: .copyToClipboard):
    guard
      let cell = state.cells.first(where: { $0.id == id })
    else { return .none }
    
    let otp: String
    
    switch cell {
    case .hotp(let hotpCell):
      otp = hotpCell.currentPassword.replacingOccurrences(of: " ", with: "")
    case .totp(let totpCell):
      otp = totpCell.currentPassword.replacingOccurrences(of: " ", with: "")
    }
    
    guard
      otp.allSatisfy(\.isNumber)
    else { return .none }
    
    return .fireAndForget {
      environment.clipboard(otp)
    }
    
  case .password(let id, action: .delete):
    guard
      let index = state.passwords.firstIndex(where: { $0.id == id })
    else { return .none }
    
    let passwordToRemove = state.passwords.remove(at: index)
    
    return .fireAndForget {
      try? environment.passwordStore.removePassword(passwordToRemove)
    }
    
    
  case .password(let id, action: .edit):
    print("EDITED PASSWORD WITH ID: \(id)")
    
    return .none
    
  case .password(let id, .updateCounter):
    guard
      var password = state.passwords.first(where: { $0.id == id }),
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
    
  case .reorder(let source, let destination):
    state.passwords.move(fromOffsets: source, toOffset: destination)
    let newIds = state.passwords.map(\.id)
    
    return .fireAndForget {
      environment.idStore.saveIds(newIds)
    }
    
  case .scanner(.dismissButtonTapped):
    state.isScannerSheetPresented = false
    return .none
    
  case .scanner(.manualEntryButtonTapped):
    state.isScannerSheetPresented = false
    // TODO: present add password sheet
    return .none
    
  case .scanner(.qrCodeFound):
    state.isScannerSheetPresented = false
    // TODO: present add password sheet
    return .none
    
  case .setScannerSheet(let isPresented):
    state.isScannerSheetPresented = isPresented
    return .none
    
  case .updatePassword(let password):
    return .fireAndForget {
      try? environment.passwordStore.savePassword(password)
    }
    
  case .passwords(.failure(let error)):
    print("FAILURE RETURNING PASSWORDS: \(error)")
    return .none
  }
}
