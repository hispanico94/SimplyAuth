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
              get: { $0.qrCodeString },
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
        .alert(
          item: viewStore.binding(
            get: { $0.errorAlertMessage.map(ErrorMessage.init) },
            send: ScannerAction.errorAlertDismissed
          ),
          content: { Alert(title: Text($0.title), message: Text($0.message)) }
        )
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
