//
//  SimplyAuthApp.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/08/2020.
//

import ComposableArchitecture
import SwiftUI

@main
struct SimplyAuthApp: App {
    var body: some Scene {
        WindowGroup {
          HomeView(
            store: Store(
              initialState: HomeState(
                passwords: [],
                unixEpochSeconds: UInt64(Date().timeIntervalSince1970)
              ),
              reducer: homeReducer,
              environment: .live
            )
          )
        }
    }
}
