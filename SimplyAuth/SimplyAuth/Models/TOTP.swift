import Foundation

struct TOTP: Codable {
  var digits: UInt8 = 6
  var period: Int = 30
}

extension TOTP: Equatable { }
