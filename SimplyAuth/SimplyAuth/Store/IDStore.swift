//
//  IDStore.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import Combine
import Foundation

private let idKey = "idKey"

struct IDStore {
  var saveIds: ([UUID]) -> Void
  var getIds: () -> AnyPublisher<[UUID], Never>
}

// MARK: Live implementation

extension IDStore {
  static let live = IDStore(
    saveIds: { ids in
      let idData = try? JSONEncoder().encode(ids)
      UserDefaults.standard
        .setValue(idData, forKey: idKey)
    },
    getIds: {
      guard
        let idData = UserDefaults.standard.data(forKey: idKey),
        let ids = try? JSONDecoder().decode([UUID].self, from: idData)
      else { return Just([]).eraseToAnyPublisher() }
      
      return Just(ids).eraseToAnyPublisher()
    }
  )
}

// MARK: Mock implementation

extension IDStore {
  static let mock = IDStore(
    saveIds: { print("IDs saved: \($0)") },
    getIds: {
      Just([
        UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
      ])
      .eraseToAnyPublisher()
    }
  )
}
