//
//  KeychainError.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 06/08/2020.
//

import Foundation

extension Keychain {
  enum Error: Swift.Error {
    case dataExtractionError(account: String)
    case unhandledError(message: String)
  }
}

extension Keychain.Error: LocalizedError {
    var errorDescription: String? {
      switch self {
      case .dataExtractionError(let account):
        return "An error occurred while extracting the found data for account \(account)"
      case .unhandledError(let message):
        return message
      }
    }
}
