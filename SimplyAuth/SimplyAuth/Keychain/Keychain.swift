import Foundation
import Security

struct Keychain {
  let accessGroup: String?
  let service: String
  
  private var defaultQuery: [String: Any] {
    var query: [String: Any] = [
      String(kSecClass): kSecClassGenericPassword,
      String(kSecAttrService): service,
      String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlocked
    ]
    
    if let accessGroup = accessGroup {
      query[String(kSecAttrAccessGroup)] = accessGroup
    }
    
    return query
  }
  
  
  public func saveData(_ data: Data, forAccount account: String) throws {
    var query = defaultQuery
    query[String(kSecAttrAccount)] = account
    
    let matchingResult = SecItemCopyMatching(query as CFDictionary, nil)
    
    switch matchingResult {
    case errSecSuccess:
      let attributesToUpdate: [String: Any] = [String(kSecValueData): data]
      let updateResult = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
      if updateResult != errSecSuccess {
        throw error(from: updateResult)
      }
      
    case errSecItemNotFound:
      query[String(kSecValueData)] = data
      let addResult = SecItemAdd(query as CFDictionary, nil)
      if addResult != errSecSuccess {
        throw error(from: addResult)
      }
      
    default:
      throw error(from: matchingResult)
    }
  }
  
  public func getData(forAccount account: String) throws -> Data? {
    var query = defaultQuery
    query[String(kSecMatchLimit)] = kSecMatchLimitOne
    query[String(kSecReturnAttributes)] = kCFBooleanTrue
    query[String(kSecReturnData)] = kCFBooleanTrue
    query[String(kSecAttrAccount)] = account
    
    var queryResult: AnyObject?
    let matchingResult = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query as CFDictionary, $0)
    }
    
    switch matchingResult {
    case errSecSuccess:
      guard
        let queriedItem = queryResult as? [String: Any],
        let data = queriedItem[String(kSecValueData)] as? Data
      else { throw Error.dataExtractionError(account: account) }
      
      return data
      
    case errSecItemNotFound:
      return nil
      
    default:
      throw error(from: matchingResult)
    }
  }
  
  public func removeData(forAccount account: String) throws {
    var query = defaultQuery
    query[String(kSecAttrAccount)] = account
    
    let deletionResult = SecItemDelete(query as CFDictionary)
    
    guard
      deletionResult == errSecSuccess
        || deletionResult == errSecItemNotFound
    else { throw error(from: deletionResult) }
  }
  
  public func removeAllData() throws {
    let query = defaultQuery
    
    let deletionResult = SecItemDelete(query as CFDictionary)
    
    guard
      deletionResult == errSecSuccess
        || deletionResult == errSecItemNotFound
    else { throw error(from: deletionResult) }
  }
  
  private func error(from status: OSStatus) -> Keychain.Error {
    let message = SecCopyErrorMessageString(status, nil) as String?
      ?? "An unknown error error occurred. Status: \(status)"
    return Error.unhandledError(message: message)
  }
  
}
