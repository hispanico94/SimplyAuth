//
//  HOTPView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 25/09/2020.
//

import SwiftUI

struct HOTPView: View {
  var state: HOTPCell
  var onRefresh: () -> Void
  
  var body: some View {
    VStack(spacing: 8) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(state.issuer)
            .font(.headline)
          Text(state.label)
            .font(.subheadline)
        }
        
        Spacer()
        
        Button(action: onRefresh) {
          Image(systemName: "arrow.clockwise.circle")
            .font(.largeTitle)
        }
      }
      
      Text(state.currentPassword)
        .font(.largeTitle)
    }
    .padding(16)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .shadow(radius: 4, y: -2)
  }
}

struct HOTPView_Previews: PreviewProvider {
  static var previews: some View {
    HOTPView(
      state: HOTPCell(
        id: .allZeros,
        issuer: "Gmail",
        label: "foobar@gmail.com",
        currentPassword: "351 894"
      ),
      onRefresh: { }
    )
  }
}
