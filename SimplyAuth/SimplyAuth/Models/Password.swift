import Foundation

struct Password: Codable {
  enum Typology {
    case counterBased(HOTP)
    case timeBased(TOTP)
  }
  
  var id: UUID = UUID()
  var isFromQRCode: Bool = false
  var typology: Typology
}

extension Password.Typology: Codable {
  enum CodingKeys: CodingKey {
    case counterBased
    case timeBased
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    do {
      let hotp = try container.decode(HOTP.self, forKey: .counterBased)
      self = .counterBased(hotp)
    } catch {
      let totp = try container.decode(TOTP.self, forKey: .timeBased)
      self = .timeBased(totp)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case .counterBased(let hotp):
      try container.encode(hotp, forKey: .counterBased)
    case .timeBased(let totp):
      try container.encode(totp, forKey: .timeBased)
    }
  }
}
