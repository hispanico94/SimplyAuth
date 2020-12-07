//
//  MessageBar.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 07/12/2020.
//

import SwiftUI

struct MessageBar: View {
  var text: String
  var body: some View {
    Text(text)
      .padding(.vertical, 16)
      .padding(.horizontal, 32)
      .background(
        Capsule()
          .foregroundColor(.green)
          .shadow(radius: 4, y: -2)
      )
  }
}

struct MessageBar_Previews: PreviewProvider {
  static var previews: some View {
    MessageBar(text: "Copied OTP 123456!")
  }
}
