import Foundation

struct HOTP {
  var secret: String
  var issuer: String
  var label: String
  var algorithm: Algorithm = .sha256
  var digits: UInt8 = 6
  var counter: UInt = 0
}
