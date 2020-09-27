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
      NavigationView {
        ScrollView {
          VStack {
            ForEach(viewStore.cells) { cell in
              getCellView(
                from: cell,
                onRefresh: { viewStore.send(.password(id: cell.id, action: .updateCounter)) }
              )
              .padding(.horizontal)
              .padding(.vertical, 8)
              .contextMenu {
                Button(
                  action: { viewStore.send(.password(id: cell.id, action: .copyToClipboard)) },
                  label: { Label("Copy", systemImage: "doc.on.doc") })
                Button(
                  action: { viewStore.send(.password(id: cell.id, action: .edit)) },
                  label: { Label("Edit", systemImage: "square.and.pencil") })
                Button(
                  action: { viewStore.send(.password(id: cell.id, action: .delete)) },
                  label: { Label("Delete", systemImage: "trash").foregroundColor(.red) })
              }
            }
            .onMove { viewStore.send(.reorder(source: $0, destination: $1)) }
          }
          .navigationBarItems(trailing: EditButton())
          .onAppear { viewStore.send(.onAppear) }
          .onDisappear { viewStore.send(.onDisappear) }
        }
      }
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
        environment: .mock
      )
    )
  }
}
