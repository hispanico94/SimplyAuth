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
    VStack(spacing: 4) {
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
    .previewLayout(.sizeThatFits)
  }
}
