import Foundation

struct HOTP: Codable {
  var digits: UInt8 = 6
  var counter: UInt = 0
}

extension HOTP: Equatable { }
