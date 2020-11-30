//
//  TOTPView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 22/09/2020.
//

import SwiftUI

struct TOTPView: View {
  var state: TOTPCell
  
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
        
        Gauge(
          percent: CGFloat(state.percentTimeLeft),
          text: state.timeLeft,
          color: state.timeRemainingLow ? .red : .green
        )
      }
      
      Text(state.currentPassword)
        .font(.largeTitle)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color(.secondarySystemBackground))
        .shadow(radius: 4, y: -2)
    )
    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

struct TOTPView_Previews: PreviewProvider {
  static var previews: some View {
    TOTPView(state: TOTPCell(
      id: .allZeros,
      issuer: "Gmail",
      label: "foobar@gmail.com",
      currentPassword: "351 894",
      timeLeft: "13",
      percentTimeLeft: 43.3,
      timeRemainingLow: false
    ))
  }
}
