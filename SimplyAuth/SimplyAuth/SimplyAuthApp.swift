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
                unixEpochSeconds: 1601200819
              ),
              reducer: homeReducer,
              environment: .mockDateLive
            )
          )
        }
    }
}
