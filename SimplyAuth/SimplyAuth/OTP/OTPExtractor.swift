//
//  OTPExtractor.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 19/09/2020.
//

import CryptoKit
import Foundation

enum OTPExtractor {
  static func totpCode(from password: Password, unixEpochSeconds: UInt) -> String? {
    guard
      case .totp(let interval) = password.typology,
      let symmetricKey = simmetricKey(fromSecret: password.secret)
    else { return nil }
    
    return getOTPCode(
      key: symmetricKey,
      authenticationNumber: (unixEpochSeconds / interval).bigEndian,
      algorithm: password.algorithm,
      digits: password.digits
    )
  }
  
  static func hotpCode(from password: Password) -> String? {
    guard
      case .totp(let counter) = password.typology,
      let symmetricKey = simmetricKey(fromSecret: password.secret)
    else { return nil }
    
    return getOTPCode(
      key: symmetricKey,
      authenticationNumber: counter.bigEndian,
      algorithm: password.algorithm,
      digits: password.digits
    )
  }
}

// MARK: - Private helper functions

private func simmetricKey(fromSecret secret: String) -> SymmetricKey? {
  secret
    .data(using: .ascii)
    .map(SymmetricKey.init(data:))
}

private func getOTPCode(key: SymmetricKey, authenticationNumber: UInt, algorithm: Algorithm, digits: UInt8) -> String? {
  var mutableAuthenticationNumber = authenticationNumber
  let authenticationData = Data(bytes: &mutableAuthenticationNumber, count: MemoryLayout<UInt>.size)
  
  let truncatedHash: UInt32
  
  switch algorithm {
  case .sha1:
    let resultHash = HMAC<Insecure.SHA1>.authenticationCode(for: authenticationData, using: key)
    truncatedHash = resultHash.withUnsafeBytes(truncateHash(_:))
    
  case .sha256:
    let resultHash = HMAC<SHA256>.authenticationCode(for: authenticationData, using: key)
    truncatedHash = resultHash.withUnsafeBytes(truncateHash(_:))
    
  case .sha512:
    let resultHash = HMAC<SHA512>.authenticationCode(for: authenticationData, using: key)
    truncatedHash = resultHash.withUnsafeBytes(truncateHash(_:))
  }
  
  let otpCode = truncatedHash % UInt32(pow(10, Float(digits)))
  
  return formatNumber(otpCode, forNumberOfDigits: digits)
}

private func truncateHash(_ pointer: UnsafeRawBufferPointer) -> UInt32 {
  let offset = pointer[pointer.endIndex - 1] & 0x0f
  
  let offsetStartIndex = pointer.startIndex + Int(offset)
  
  return pointer.baseAddress!
    .advanced(by: offsetStartIndex)
    .bindMemory(to: UInt32.self, capacity: 1)
    .pointee
    .bigEndian
    & 0x7fffffff
}

private func formatNumber(_ number: UInt32, forNumberOfDigits digits: UInt8) -> String? {
  let f = NumberFormatter()
  
  f.numberStyle = .none
  
  f.minimumFractionDigits = 0
  f.maximumFractionDigits = 0
  f.minimumIntegerDigits = Int(digits)
  f.maximumIntegerDigits = Int(digits)
  
  f.groupingSeparator = " "
  f.usesGroupingSeparator = true
  switch digits {
  case 6:
    f.groupingSize = 3
  case 7:
    f.groupingSize = 4
  case 8:
    f.groupingSize = 2
  default:
    f.groupingSize = .max
  }
  
  return f.string(from: NSNumber(value: number))
}
