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
    VStack(spacing: 4) {
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
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(.accentColor)
      }
      
      Text(state.currentPassword)
        .font(.largeTitle)
    }
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
    .previewLayout(.sizeThatFits)
  }
}
