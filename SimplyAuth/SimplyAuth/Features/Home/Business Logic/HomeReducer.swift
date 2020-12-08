//
//  HomeReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 11/09/2020.
//

import ComposableArchitecture
import Foundation

let homeReducer = scannerReducer
  .optional()
  .pullback(
    state: \HomeState.optionalScanner,
    action: /HomeAction.scanner,
    environment: { ScannerEnvironment(feedback: $0.feedback) })
  .combined(
    with: editReducer
      .optional()
      .pullback(
        state: \HomeState.optionalEdit,
        action: /HomeAction.edit,
        environment: { _ in })
  )
  .combined(with: _homeReducer)

private let _homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { (state, action, environment) -> Effect<HomeAction, Never> in
  struct ClockTimerID: Hashable { }
  struct MessageCancellableID: Hashable { }
  
  switch action {
  case .addPassword(let password):
    return addPassword(password, state: &state, environment: environment)
    
  case .clockTick(let secondsSince1970):
    state.unixEpochSeconds = secondsSince1970
    return Effect.none
    
  case .ids(let ids):
    return environment.passwordStore
      .getPasswords(ids)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .catchToEffect()
      .map(HomeAction.passwords)
    
  case .edit(.save):
    return savePasswordFromEdit(state: &state, environment: environment)
    
  case .edit:
    return Effect.none
    
  case .onAppear:
    return onAppear(state: &state, timerId: ClockTimerID(), environment: environment)
    
  case .password(let id, action: .copyToClipboard):
    return copyPasswordToClipboard(passwordId: id, messageCancellableId: MessageCancellableID(), state: state, environment: environment)
    
  case .password(let id, action: .delete):
    return deletePassword(passwordId: id, state: &state, environment: environment)
    
  case .password(let id, action: .edit):
    state.passwordToEdit = state.passwords.first(where: { $0.id == id })
    return Effect.none
    
  case .password(let id, .updateCounter):
    return updatePasswordCounter(passwordId: id, state: &state, environment: environment)
    
  case .passwords(.success(let passwords)):
    state.passwords = passwords
    return Effect.none
    
  case .reorder(let source, let destination):
    state.passwords.move(fromOffsets: source, toOffset: destination)
    let newIds = state.passwords.map(\.id)
    
    return Effect.fireAndForget {
      environment.idStore.saveIds(newIds)
    }
    
  case .scanner(.dismissButtonTapped):
    state.optionalScanner = nil
    return Effect.none
    
  case .scanner(.passwordCreated(let newPassword)):
    return saveCreatedPassword(newPassword: newPassword, state: &state, environment: environment)
    
  case .scanner:
    return Effect.none
    
  case .setEditNavigation(false):
    state.passwordToEdit = nil
    return Effect.none
    
  case .setEditNavigation(true):
    return Effect.none
    
  case .setScannerSheet(let isPresented):
    state.optionalScanner = isPresented ? .init() : nil
    return Effect.none
    
  case .updatePassword(let password):
    return Effect.fireAndForget {
      try? environment.passwordStore.savePassword(password)
    }
    
  case .showMessage(let message):
    state.message = message
    
    return Effect(value: HomeAction.hideMessage)
      .delay(for: .seconds(3), scheduler: environment.mainQueue)
      .eraseToEffect()
      .cancellable(id: MessageCancellableID(), cancelInFlight: true)
    
  case .hideMessage:
    state.message = nil
    return Effect.none
    
  case .passwords(.failure(let error)):
    print("FAILURE RETURNING PASSWORDS: \(error)")
    return Effect.none
  }
}

// MARK: - Helper Functions

private func addPassword(_ password: Password, state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  state.passwords.append(password)
  let newIds = state.passwords.map(\.id)
  
  return Effect.fireAndForget {
    environment.idStore.saveIds(newIds)
    try? environment.passwordStore.savePassword(password)
  }
}

private func savePasswordFromEdit(state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  guard
    let editedPassword = state.passwordToEdit,
    let oldPasswordIndex = state.passwords.firstIndex(where: { $0.id == editedPassword.id })
  else { return Effect.none }
  
  state.passwords[oldPasswordIndex] = editedPassword
  state.passwordToEdit = nil
  
  return Effect.fireAndForget {
    try? environment.passwordStore.savePassword(editedPassword)
  }
}

private func onAppear(state: inout HomeState, timerId: AnyHashable, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  guard state.firstAppearance else {
    return Effect.none
  }
  
  defer { state.firstAppearance = false }
  
  let secondOffset = environment.date()
    .timeIntervalSince1970
    .truncatingRemainder(dividingBy: 1)
  
  return Effect.merge (
    environment.idStore
      .getIds()
      .map(HomeAction.ids)
      .eraseToEffect(),
    Effect(value: environment.date().timeIntervalSince1970)
      .map(UInt.init)
      .map(HomeAction.clockTick)
      .eraseToEffect(),
    Effect(value: ())
      .delay(for: .seconds(1 - secondOffset), tolerance: .milliseconds(10), scheduler: environment.mainQueue)
      .flatMap { _ in Effect.timer(id: timerId, every: 1, tolerance: .milliseconds(10), on: environment.mainQueue) }
      .map { _ in environment.date().timeIntervalSince1970 }
      .map(UInt.init)
      .map(HomeAction.clockTick)
      .eraseToEffect()
  )
}

private func copyPasswordToClipboard(passwordId: UUID, messageCancellableId: AnyHashable, state: HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  guard
    let cell = state.cells.first(where: { $0.id == passwordId })
  else { return Effect.none }
  
  let otp: String
  
  switch cell {
  case .hotp(let hotpCell):
    otp = hotpCell.currentPassword.replacingOccurrences(of: " ", with: "")
  case .totp(let totpCell):
    otp = totpCell.currentPassword.replacingOccurrences(of: " ", with: "")
  }
  
  guard
    otp.allSatisfy(\.isNumber)
  else { return Effect.none }
  
  return Effect.merge(
    Effect.fireAndForget {
      environment.feedback.selectionFeedback()
      environment.clipboard(otp)
    },
    Effect.cancel(id: messageCancellableId),
    Effect(value: HomeAction.showMessage("OTP \(otp) copied!"))
  )
}

private func deletePassword(passwordId: UUID, state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  guard
    let index = state.passwords.firstIndex(where: { $0.id == passwordId })
  else { return .none }
  
  let passwordToRemove = state.passwords.remove(at: index)
  
  return Effect.fireAndForget {
    try? environment.passwordStore.removePassword(passwordToRemove)
  }
}

private func updatePasswordCounter(passwordId: UUID, state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  guard
    let index = state.passwords.firstIndex(where: { $0.id == passwordId }),
    case .hotp(var counter) = state.passwords[index].typology
  else { return .none }
  
  var password = state.passwords[index]
  counter += 1
  password.typology = .hotp(counter)
  
  state.passwords[index] = password
  
  return .fireAndForget {
    try? environment.passwordStore.savePassword(password)
  }
}

private func saveCreatedPassword(newPassword: Password, state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
  state.passwords.append(newPassword)
  state.optionalScanner = nil
  
  let newIds = state.passwords.map(\.id)
  return Effect.merge(
    Effect.fireAndForget {
      environment.idStore.saveIds(newIds)
    },
    Effect.fireAndForget {
      try? environment.passwordStore.savePassword(newPassword)
    }
  )
}
