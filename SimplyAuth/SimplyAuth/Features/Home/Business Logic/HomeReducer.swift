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
    let newIds = state.addPassword(password)
    
    return Effect.fireAndForget {
      environment.idStore.saveIds(newIds)
      try? environment.passwordStore.savePassword(password)
    }
    
  case .clockTick(let secondsSince1970):
    state.unixEpochSeconds = secondsSince1970
    return Effect.none
    
  case .delete(let offsets):
    let passwordsToDelete = offsets.map { state.passwords[$0] }
    state.passwords.remove(atOffsets: offsets)
    
    return Effect.fireAndForget {
      passwordsToDelete.forEach {
        try? environment.passwordStore.removePassword($0)
      }
    }
    
  case .hideMessageBar:
    state.message = nil
    return Effect.none
    
  case .ids(let ids):
    return environment.passwordStore
      .getPasswords(ids)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .catchToEffect()
      .map(HomeAction.passwords)
    
  case .edit(.save):
    guard
      let editedPassword = state.saveEditedPassword()
    else { return Effect.none }
    
    return Effect.fireAndForget {
      try? environment.passwordStore.savePassword(editedPassword)
    }
    
  case .edit:
    return Effect.none
    
  case .onAppear:
    return onAppear(state: &state, timerId: ClockTimerID(), environment: environment)
    
  case .password(let id, action: .copyToClipboard):
    return copyPasswordToClipboard(passwordId: id, messageCancellableId: MessageCancellableID(), state: &state, environment: environment)
    
  case .password(let id, action: .delete):
    guard
      let deletedPassword = state.deletePassword(with: id)
    else { return Effect.none }
    
    return Effect.fireAndForget {
      try? environment.passwordStore.removePassword(deletedPassword)
    }
    
  case .password(let id, action: .edit):
    state.passwordToEdit = state.passwords.first(where: { $0.id == id })
    return Effect.none
    
  case .password(let id, .updateCounter):
    guard
      let password = state.updateCounter(forPasswordWithId: id)
    else { return Effect.none }
    
    return Effect.fireAndForget {
      try? environment.passwordStore.savePassword(password)
    }
    
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
    let newIds = state.saveCreatedPassword(newPassword)
    
    return Effect.merge(
      Effect.fireAndForget {
        environment.idStore.saveIds(newIds)
      },
      Effect.fireAndForget {
        try? environment.passwordStore.savePassword(newPassword)
      }
    )
    
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
    
  case .passwords(.failure(let error)):
    print("FAILURE RETURNING PASSWORDS: \(error)")
    return Effect.none
  }
}

// MARK: - HomeState utility extension

private extension HomeState {
  mutating func addPassword(_ password: Password) -> [UUID] {
    passwords.append(password)
    return passwords.map(\.id)
  }
  
  mutating func saveEditedPassword() -> Password? {
    guard
      let editedPassword = passwordToEdit,
      let oldPasswordIndex = passwords.firstIndex(where: { $0.id == editedPassword.id })
    else { return nil }
    
    passwords[oldPasswordIndex] = editedPassword
    passwordToEdit = nil
    
    return editedPassword
  }
  
  mutating func deletePassword(with id: UUID) -> Password? {
    guard
      let index = passwords.firstIndex(where: { $0.id == id })
    else { return nil }
    
    return passwords.remove(at: index)
  }
  
  mutating func updateCounter(forPasswordWithId id: UUID) -> Password? {
    guard
      let index = passwords.firstIndex(where: { $0.id == id }),
      case .hotp(var counter) = passwords[index].typology
    else { return nil }
    
    var password = passwords[index]
    counter += 1
    password.typology = .hotp(counter)
    
    passwords[index] = password
    
    return password
  }
  
  mutating func saveCreatedPassword(_ newPassword: Password) -> [UUID] {
    passwords.append(newPassword)
    optionalScanner = nil
    
    return passwords.map(\.id)
  }
}

// MARK: - Helper Functions


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
      .map(UInt64.init)
      .map(HomeAction.clockTick)
      .eraseToEffect(),
    Effect(value: ())
      .delay(for: .seconds(1 - secondOffset), tolerance: .milliseconds(10), scheduler: environment.mainQueue)
      .flatMap { _ in Effect.timer(id: timerId, every: 1, tolerance: .milliseconds(10), on: environment.mainQueue) }
      .map { _ in environment.date().timeIntervalSince1970 }
      .map(UInt64.init)
      .map(HomeAction.clockTick)
      .eraseToEffect()
  )
}

private func copyPasswordToClipboard(passwordId: UUID, messageCancellableId: AnyHashable, state: inout HomeState, environment: HomeEnvironment) -> Effect<HomeAction, Never> {
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
  
  state.message = "OTP \(otp) copied!"
  
  return Effect.merge(
    Effect.fireAndForget {
      environment.feedback.selectionFeedback()
      environment.clipboard(otp)
    },
    Effect.concatenate(
      Effect.cancel(id: messageCancellableId),
      Effect(value: HomeAction.hideMessageBar)
        .delay(for: .seconds(3), scheduler: environment.mainQueue)
        .eraseToEffect()
        .cancellable(id: messageCancellableId, cancelInFlight: true)
    )
  )
}
