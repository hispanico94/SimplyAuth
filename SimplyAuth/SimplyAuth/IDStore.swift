//
//  IDStore.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 05/08/2020.
//

import Foundation

private let idKey = "idKey"

struct IDStore {
  var saveIds: ([UUID]) -> Void
  var getIds: () -> [UUID]
}

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
      else { return [] }
      
      return ids
    }
  )
}
