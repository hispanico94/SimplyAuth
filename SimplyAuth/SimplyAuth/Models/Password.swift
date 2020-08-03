import Foundation

struct Password {
  enum Typology {
    case counterBased(HOTP)
    case timeBased(TOTP)
  }
  
  var id: UUID = UUID()
  var isFromQRCode: Bool = false
  var typology: Typology
}
