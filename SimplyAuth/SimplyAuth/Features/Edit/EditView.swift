//
//  EditView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 25/10/2020.
//

import ComposableArchitecture
import SwiftUI

struct EditView: View {
  let store: Store<EditState, EditAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        Form {
          Section(header: Text("Issuer")) {
            issuerTextField(viewStore)
          }
          Section(header: Text("Account")) {
            accountTextField(viewStore)
          }
          
          if viewStore.password.isFromQRCode == false {
            Section(header: Text("Secret")) {
              secretTextField(viewStore)
            }
            
            Section(header: Text("Advanced Options")) {
              algorithmPicker(viewStore)
              
              digitsPicker(viewStore)
              
              typologyPicker(viewStore)
              
              typologySpecificPicker(viewStore)
            }
          }
        }
        .navigationTitle(viewStore.isNewPassword ? "New Password" : "Edit Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
          leading: Button("Cancel", action: { viewStore.send(.cancel) }),
          trailing: Button("Save", action: { viewStore.send(.save) })
        )
      }
    }
  }
  
  private func issuerTextField(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    TextField("Issuer", text: viewStore.binding(
      get: \.password.issuer,
      send: EditAction.issuerChanged
    ))
  }
  
  private func accountTextField(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    TextField("Account", text: viewStore.binding(
      get: \.password.label,
      send: EditAction.accountChanged
    ))
  }
  
  private func secretTextField(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    TextField("secret", text: viewStore.binding(
      get: \.password.secret,
      send: EditAction.secretChanged
    ))
    .disabled(viewStore.password.isFromQRCode)
  }
  
  private func algorithmPicker(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    Picker(
      selection: viewStore.binding(
        get: \.password.algorithm,
        send: EditAction.algorithmChanged
      ),
      label: Text("Algorithm"),
      content: {
        ForEach(viewStore.algorithms) {
          Text($0.description).tag($0)
        }
      }
    )
  }
  
  private func digitsPicker(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    Picker(
      selection: viewStore.binding(
        get: \.password.digits,
        send: EditAction.digitsChanged
      ),
      label: Text("Digits"),
      content: {
        ForEach(viewStore.digits) {
          Text("\($0)").tag($0)
        }
      }
    )
  }
  
  private func typologyPicker(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    Picker(
      selection: viewStore.binding(
        get: \.password.typology,
        send: EditAction.passwordTypologyChanged
      ),
      label: Text("Typology"),
      content: {
        ForEach(viewStore.passwordTypologies) {
          Text("\($0.id)").tag($0)
        }
      }
    )
    .pickerStyle(SegmentedPickerStyle())
  }
  
  private func typologySpecificPicker(_ viewStore: ViewStore<EditState, EditAction>) -> some View {
    HStack {
      switch viewStore.password.typology {
      case .totp(let interval):
        Text("Interval")
        
        Spacer()
        
        TextField("", text: viewStore.binding(
          get: { _ in "\(interval)" },
          send: EditAction.periodChanged
        )
        )
        .frame(width: 100)
        .multilineTextAlignment(.trailing)
        
        Text("s")
        
      case .hotp(let counter):
        Text("Counter")
        
        Spacer()
        
        TextField("", text: viewStore.binding(
          get: { _ in "\(counter)" },
          send: EditAction.counterChanged
        )
        )
        .frame(width: 100)
        .multilineTextAlignment(.trailing)
      }
    }
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .keyboardType(.decimalPad)
  }
}

struct EditView_Previews: PreviewProvider {
  static var previews: some View {
    EditView(
      store: Store(
        initialState: EditState(
          password: Password(
            secret: "JBSWY3DPEHPK3PXP",
            issuer: "Xcode",
            label: "Test"
          )),
        reducer: editReducer,
        environment: ()
      )
    )
  }
}
