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
        ZStack {
          emptyNavigationLink(viewStore: viewStore)
          
          List {
            ForEach(viewStore.cells) { cell in
              getCellView(
                from: cell,
                onRefresh: { viewStore.send(.password(id: cell.id, action: .updateCounter)) }
              )
              .configure(cellId: cell.id, viewStore: viewStore)
            }
            .onMove { viewStore.send(.reorder(source: $0, destination: $1)) }
          }
          .listStyle(PlainListStyle())
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarItems(
            leading: Button(
              action: { viewStore.send(.setScannerSheet(isPresented: true)) },
              label: {
                Image(systemName: "plus.circle")
                  .imageScale(.large)
              }
            ),
            trailing: EditButton()
          )
          .scannerViewSheet(store: store, viewStore: viewStore)
          .onAppear { viewStore.send(.onAppear) }
          
          messageBar(viewStore: viewStore)
        }
      }
    }
  }
}

// MARK: - Components

private extension HomeView {
  func emptyNavigationLink(viewStore: ViewStore<HomeState, HomeAction>) -> some View {
    NavigationLink(
      destination: IfLetStore(store.scope(
        state: \.optionalEdit,
        action: HomeAction.edit
      ),
      then: EditView.init(store:)
      ),
      isActive: viewStore.binding(
        get: \.isEditNavigationActive,
        send: HomeAction.setEditNavigation(isActive:)
      ),
      label: { EmptyView() }
    )
    .frame(width: 0, height: 0)
  }
  
  func messageBar(viewStore: ViewStore<HomeState, HomeAction>) -> some View {
    VStack {
      if viewStore.isMessageShown {
        MessageBar(text: viewStore.message!)
          .padding(.top, 8)
          .transition(.move(edge: .top))
          .animation(.easeInOut)
          .zIndex(1)
      }
      
      Spacer()
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

// MARK: - Operators

private extension View {
  func configure(cellId: UUID, viewStore: ViewStore<HomeState, HomeAction>) -> some View {
    self
      .padding(.vertical, 8)
      .contextMenu {
        Button(
          action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
              viewStore.send(.password(id: cellId, action: .copyToClipboard))
            }
          },
          label: { Label("Copy", systemImage: "doc.on.doc") })
        Button(
          action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
              viewStore.send(.password(id: cellId, action: .edit))
            }
          },
          label: { Label("Edit", systemImage: "square.and.pencil") })
        
        Divider()
        
        Button(
          action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
              withAnimation {
                viewStore.send(.password(id: cellId, action: .delete))
              }
            }
          },
          label: { Label("Delete", systemImage: "trash") })
          .foregroundColor(.red)
      }
      .onTapGesture {
        viewStore.send(.password(id: cellId, action: .copyToClipboard))
      }
  }
  
  func scannerViewSheet(store: Store<HomeState, HomeAction>, viewStore: ViewStore<HomeState, HomeAction>) -> some View {
    self
      .sheet(
        isPresented: viewStore.binding(
          get: \.isScannerPresented,
          send: HomeAction.setScannerSheet(isPresented:)
        ),
        content: {
          IfLetStore(
            store.scope(
              state: \.optionalScanner,
              action: HomeAction.scanner
            ),
            then: ScannerView.init(store:)
          )
        }
      )
  }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: Store(
        initialState: HomeState(
          passwords: [
            Password(
              id: UUID.allZeros,
              secret: "ksahdkaskdaskj",
              issuer: "MockPasswordStore",
              label: "mocked OTP"),
            Password(
              id: UUID.allZeros,
              secret: "ksahdkaskdaskj",
              issuer: "MockPasswordStore",
              label: "mocked OTP"),
            Password(
              id: UUID.allZeros,
              secret: "ksahdkaskdaskj",
              issuer: "MockPasswordStore",
              label: "mocked OTP"),
            Password(
              id: UUID.allZeros,
              secret: "ksahdkaskdaskj",
              issuer: "MockPasswordStore",
              label: "mocked OTP"),
            Password(
              id: UUID.allZeros,
              secret: "ksahdkaskdaskj",
              issuer: "MockPasswordStore",
              label: "mocked OTP"),
            
          ],
          unixEpochSeconds: 1601200819
        ),
        reducer: homeReducer,
        environment: .mock
      )
    )
  }
}
