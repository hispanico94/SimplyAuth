//
//  PasswordStore.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import Foundation

// MARK: - PasswordStore

struct PasswordStore {
  var savePassword: (Password) throws -> Void
  var savePassowrds: ([Password]) throws -> Void
  var getPassword: (UUID) throws -> Password?
  var getPasswords: ([UUID]) throws -> [Password]
}

extension PasswordStore {
  enum Error: Swift.Error {
    case encodingError
    case decodingError
    case storingError(description: String?)
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
    }
  }
}

// MARK: Live implementation

extension PasswordStore {
  static let live = PasswordStore(
    savePassword: savePassword(_:),
    savePassowrds: savePasswords(_:),
    getPassword: getPassword(from:),
    getPasswords: getPasswords(from:)
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

private func getPassword(from id: UUID) throws -> Password? {
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

private func getPasswords(from ids: [UUID]) throws -> [Password] {
  try ids.compactMap(getPassword(from:))
}
