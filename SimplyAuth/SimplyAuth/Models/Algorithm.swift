import Foundation

enum Algorithm: String, Codable {
  case sha1
  case sha256
  case sha512
}

extension Algorithm: Identifiable {
  var id: String {
    self.rawValue
  }
}

extension Algorithm: CustomStringConvertible {
  var description: String {
    switch self {
    case .sha1:
      return "SHA1"
    case .sha256:
      return "SHA256"
    case .sha512:
      return "SHA512"
    }
  }
}

extension Algorithm: Hashable { }
