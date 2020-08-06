import Foundation

struct TOTP: Codable {
  var secret: String
  var issuer: String
  var label: String
  var algorithm: Algorithm = .sha256
  var digits: UInt8 = 6
  var period: Int = 30
}
