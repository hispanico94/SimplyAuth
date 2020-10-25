//
//  ScannerView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 01/10/2020.
//

import ComposableArchitecture
import SwiftUI

struct ScannerView: View {
  let store: Store<ScannerState, ScannerAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        ZStack {
          QRCodeScannerView(
            qrCode: viewStore.binding(
              get: { _ in "" },
              send: ScannerAction.qrCodeFound
            )
          )
          
          VStack {
            Spacer()
            
            Text("Inquadra il codice QR")
              .padding(.horizontal, 24)
              .padding(.vertical, 16)
              .background(BlurView(style: .systemThinMaterial))
              .clipShape(Capsule())
              .padding(.bottom, 16)
          }
          
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
          leading: Button(
            "Dismiss",
            action: { viewStore.send(.dismissButtonTapped) }
          ),
          trailing: Button(
            action: { viewStore.send(.manualEntryButtonTapped) },
            label: { Image(systemName: "square.and.pencil") }
          )
        )
      }
    }
  }
}

struct ScannerView_Previews: PreviewProvider {
  static var previews: some View {
    ScannerView(store: Store(
      initialState: ScannerState(),
      reducer: scannerReducer,
      environment: ()
    )
    )
  }
}
