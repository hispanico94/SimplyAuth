import Foundation

struct Password: Codable {
  enum Typology {
    case hotp(UInt64)
    case totp(UInt64)
  }
  
  var id: UUID = UUID()
  var isFromQRCode: Bool = false
  var digits: UInt8 = defaultDigits
  var algorithm: Algorithm = .defaultAlgorithm
  var typology: Typology = .defaultTotp
  
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
      let counter = try container.decode(UInt64.self, forKey: .hotp)
      self = .hotp(counter)
    } catch {
      let interval = try container.decode(UInt64.self, forKey: .totp)
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

extension Password {
  
  
  /// Initializes the Password from the standard OTP URI format
  /// - Parameter string: a string containing a standard OTP URI format
  ///
  /// The details about the format can be found on the [Google Authenticator repository](https://github.com/google/google-authenticator/wiki/Key-Uri-Format)
  init?(string: String) {
    guard
      let components = URLComponents(string: string),
      components.scheme == "otpauth",
      let typologyString = components.host,
      let queryItems = components.queryItems,
      let secret = queryItems.first(where: { $0.name == "secret" })?.value
    else { return nil }
    
    let issuerAndLabel = components.path.dropFirst().split(separator: ":")
    
    guard let label = issuerAndLabel.last.map(String.init) else { return nil }
    
    let optionalIssuerFromPath = issuerAndLabel.count == 2 ? String(issuerAndLabel.first!) : nil
    let optionalIssuerFromParams = queryItems.first(where: { $0.name == "issuer" })?.value
    
    guard
      let issuer = optionalIssuerFromPath ?? optionalIssuerFromParams
    else { return nil }
    
    // if both issuers are present they must be equal
    if let issuerFromParams = optionalIssuerFromParams,
       let issuerFromPath = optionalIssuerFromPath,
       issuerFromParams != issuerFromPath {
      return nil
    }
    
    let digits = queryItems
      .first(where: { $0.name == "digits" })
      .flatMap(\.value)
      .flatMap(UInt8.init)
      ?? Password.defaultDigits
    
    let algorithm = queryItems
      .first(where: { $0.name == "algorithm" })
      .flatMap(\.value)
      .map { $0.lowercased() }
      .flatMap(Algorithm.init(rawValue:))
      ?? .defaultAlgorithm
    
    let typology: Typology
    
    if typologyString == "hotp" {
      typology = queryItems
        .first(where: { $0.name == "counter" })
        .flatMap(\.value)
        .flatMap(UInt64.init)
        .map(Typology.hotp)
        ?? .defaultHotp
    } else if typologyString == "totp" {
      typology = queryItems
        .first(where: { $0.name == "period" })
        .flatMap(\.value)
        .flatMap(UInt64.init)
        .map(Typology.totp)
        ?? .defaultTotp
    } else {
      return nil
    }
    
    self.init(
      isFromQRCode: true,
      digits: digits,
      algorithm: algorithm,
      typology: typology,
      secret: secret,
      issuer: issuer,
      label: label
    )
  }
}


extension Password.Typology: Equatable { }

extension Password.Typology: Hashable { }
extension Password.Typology: CustomStringConvertible {
  var description: String {
    switch self {
    case .hotp:
      return "HOTP"
    case .totp:
      return "TOTP"
    }
  }
}

extension Password.Typology: Identifiable {
  public var id: String { description }
}


// MARK: - Defaults

extension Password {
  fileprivate static let defaultDigits: UInt8 = 6
}

extension Password.Typology {
  fileprivate static let defaultHotp = Self.hotp(0)
  fileprivate static let defaultTotp = Self.totp(30)
}
