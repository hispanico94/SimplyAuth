//
//  PasswordStore.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import Combine
import Foundation

// MARK: - PasswordStore

struct PasswordStore {
  var savePassword: (Password) throws -> Void
  var savePassowrds: ([Password]) throws -> Void
  var getPassword: (UUID) -> AnyPublisher<Password?, PasswordStore.Error>
  var getPasswords: ([UUID]) -> AnyPublisher<[Password], PasswordStore.Error>
  var removePassword: (Password) throws -> Void
}

extension PasswordStore {
  enum Error: Swift.Error {
    case encodingError
    case decodingError
    case storingError(description: String?)
    case unknownError
  }
}

extension PasswordStore.Error: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .encodingError:
      return "An error occurred while encoding the data for storing"
    case .decodingError:
      return "An error occurred while decoding the data from the store"
    case .storingError(let description):
      return "An error occurred while storing or retrieving the password: \(description ?? "Unknown")"
    case .unknownError:
      return "An unknown error occurred"
    }
  }
}

// MARK: Live implementation

extension PasswordStore {
  static let live = PasswordStore(
    savePassword: savePassword(_:),
    savePassowrds: savePasswords(_:),
    getPassword: getPassword(from:),
    getPasswords: getPasswords(from:),
    removePassword: removePassword(_:)
  )
}

// MARK: Mock implementation

extension PasswordStore {
  static let mock = PasswordStore(
    savePassword: { print("Password saved: \($0)") },
    savePassowrds: { print("Passwords saved: \($0)") },
    getPassword: {
      print("Requested password with UUID: \($0)")
      return Just(Password(id: $0, secret: "sfdlskje9023fjsk", issuer: "MockPasswordStore", label: "mocked OTP"))
        .setFailureType(to: PasswordStore.Error.self)
        .eraseToAnyPublisher()
    },
    getPasswords: { ids in
      print("Rquested passwords with UUIDs: \(ids)")
      let passwords = ids
        .map { Password(id: $0, secret: "dsadasdhkakgkfskòfk\(Int.random(in: 1...100))", issuer: "MockPasswordStore\(Int.random(in: 1...100))", label: "mocked OTP \(Int.random(in: 1...100))") }
      return Just(passwords)
        .setFailureType(to: PasswordStore.Error.self)
        .eraseToAnyPublisher()
    },
    removePassword: { print("Removed password: \($0)") }
  )
}

// MARK: - Private implementation

private let keychain = Keychain(accessGroup: nil, service: "com.PaoloRocca.SimplyAuth")

private func savePassword(_ password: Password) throws {
  guard
    let encodedPassword = try? JSONEncoder().encode(password)
  else { throw PasswordStore.Error.encodingError }
  
  do {
    try keychain.saveData(encodedPassword, forAccount: password.id.uuidString)
  } catch let keychainError as Keychain.Error {
    throw PasswordStore.Error.storingError(description: keychainError.errorDescription)
  } catch {
    throw PasswordStore.Error.storingError(description: error.localizedDescription)
  }
}

private func savePasswords(_ passwords: [Password]) throws {
  try passwords.forEach(savePassword(_:))
}

private func getPassword(from id: UUID) -> AnyPublisher<Password?, PasswordStore.Error> {
  do {
    return Just(try getPasswordSync(from: id))
      .setFailureType(to: PasswordStore.Error.self)
      .eraseToAnyPublisher()
  } catch let error as PasswordStore.Error {
    return Fail(error: error).eraseToAnyPublisher()
  } catch {
    return Fail(error: .unknownError).eraseToAnyPublisher()
  }
}

private func getPasswords(from ids: [UUID]) -> AnyPublisher<[Password], PasswordStore.Error> {
  do {
    return Just(try ids.compactMap(getPasswordSync(from:)))
      .setFailureType(to: PasswordStore.Error.self)
      .eraseToAnyPublisher()
  } catch let error as PasswordStore.Error {
    return Fail(error: error).eraseToAnyPublisher()
  } catch {
    return Fail(error: .unknownError).eraseToAnyPublisher()
  }
}

private func getPasswordSync(from id: UUID) throws -> Password? {
  let data: Data?
  
  do {
    data = try keychain.getData(forAccount: id.uuidString)
  } catch let keychainError as Keychain.Error {
    throw PasswordStore.Error.storingError(description: keychainError.errorDescription)
  } catch {
    throw PasswordStore.Error.storingError(description: error.localizedDescription)
  }
  
  guard let unwrappedData = data else { return nil }
  
  do {
    let password = try JSONDecoder().decode(Password.self, from: unwrappedData)
    return password
  } catch {
    throw PasswordStore.Error.decodingError
  }
}

private func removePassword(_ password: Password) throws {
  try keychain.removeData(forAccount: password.id.uuidString)
}
