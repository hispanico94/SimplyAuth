//
//  HomeView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 27/09/2020.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
  let store: Store<HomeState, HomeAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ForEach(viewStore.cells) { cell in
          getCellView(
            from: cell,
            onRefresh: { viewStore.send(.password(id: cell.id, action: .updateCounter)) }
          )
          .padding(.horizontal)
          .padding(.vertical, 8)
        }
      }
      .onAppear { viewStore.send(.onAppear) }
      .onDisappear { viewStore.send(.onDisappear) }
    }
  }
  
  @ViewBuilder func getCellView(from cell: OTPCell, onRefresh: @escaping () -> Void) -> some View {
    switch cell {
    case .hotp(let hotpCell):
      HOTPView(state: hotpCell, onRefresh: onRefresh)
    case .totp(let totpCell):
      TOTPView(state: totpCell)
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: Store(
        initialState: HomeState(
          passwords: [],
          unixEpochSeconds: 1601200819
        ),
        reducer: homeReducer,
        environment: HomeEnvironment(
          date: { Date(timeIntervalSince1970: 1601200819) },
          uuid: UUID.init,
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          idStore: .mock,
          passwordStore: .mock
        )
      )
    )
  }
}
