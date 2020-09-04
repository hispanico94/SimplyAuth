import Foundation

struct Password: Codable {
  enum Typology {
    case hotp(UInt)
    case totp(UInt)
  }
  
  var id: UUID = UUID()
  var isFromQRCode: Bool = false
  var digits: UInt8 = 6
  var algorithm: Algorithm = .sha256
  var typology: Typology = .totp(30)
  
  var secret: String
  var issuer: String
  var label: String
}

extension Password.Typology: Codable {
  enum CodingKeys: CodingKey {
    case hotp
    case totp
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    do {
      let counter = try container.decode(UInt.self, forKey: .hotp)
      self = .hotp(counter)
    } catch {
      let interval = try container.decode(UInt.self, forKey: .totp)
      self = .totp(interval)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case .hotp(let counter):
      try container.encode(counter, forKey: .hotp)
    case .totp(let interval):
      try container.encode(interval, forKey: .totp)
    }
  }
}

extension Password: Equatable { }
extension Password.Typology: Equatable { }
