//
//  OTPExtractor.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 19/09/2020.
//

import Base32
import CryptoKit
import Foundation

enum OTPExtractor {
  static func totpCode(from password: Password, unixEpochSeconds: UInt64) -> String? {
    guard
      case .totp(let interval) = password.typology,
      let base32secretData = try? Base32.decode(password.secret)
    else { return nil }
    
    return getOTPCode(
      key: SymmetricKey(data: base32secretData),
      authenticationNumber: (unixEpochSeconds / interval).bigEndian,
      algorithm: password.algorithm,
      digits: password.digits
    )
  }
  
  static func hotpCode(from password: Password) -> String? {
    guard
      case .hotp(let counter) = password.typology,
      let base32secretData = try? Base32.decode(password.secret)
    else { return nil }
    
    return getOTPCode(
      key: SymmetricKey(data: base32secretData),
      authenticationNumber: counter.bigEndian,
      algorithm: password.algorithm,
      digits: password.digits
    )
  }
}

// MARK: - Private helper functions

private func getOTPCode(key: SymmetricKey, authenticationNumber: UInt64, algorithm: Algorithm, digits: UInt8) -> String? {
  var mutableAuthenticationNumber = authenticationNumber
  let authenticationData = Data(bytes: &mutableAuthenticationNumber, count: MemoryLayout<UInt64>.size)
  
  let resultData: Data
  
  switch algorithm {
  case .sha1:
    resultData = HMAC<Insecure.SHA1>
      .authenticationCode(for: authenticationData, using: key)
      .withUnsafeBytes { Data(bytes: $0.baseAddress!, count: Insecure.SHA1.byteCount) }
    
  case .sha256:
    resultData = HMAC<SHA256>
      .authenticationCode(for: authenticationData, using: key)
      .withUnsafeBytes { Data(bytes: $0.baseAddress!, count: SHA256.byteCount) }
    
  case .sha512:
    resultData = HMAC<SHA512>
      .authenticationCode(for: authenticationData, using: key)
      .withUnsafeBytes { Data(bytes: $0.baseAddress!, count: SHA512.byteCount) }
  }
  
  let truncatedHash = resultData.withUnsafeBytes { truncateHash(pointer: $0, length: resultData.endIndex) }
  let otpCode = truncatedHash % UInt32(pow(10, Float(digits)))
  
  return formatNumber(otpCode, forNumberOfDigits: digits)
}

private func truncateHash(pointer: UnsafeRawBufferPointer, length: Int) -> UInt32 {
  let offset = pointer[length - 1] & 0x0f
  
  return (pointer.baseAddress! + Int(offset))
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
