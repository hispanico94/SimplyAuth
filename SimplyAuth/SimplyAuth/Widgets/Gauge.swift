//
//  Gauge.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 23/09/2020.
//

import SwiftUI

struct Gauge: View {
  var percent: CGFloat = 88
  var text: String? = nil
  var color: Color = .red
  @ScaledMetric var gaugeSize: CGFloat = 44
  
  private var progress: CGFloat {
    (100 - percent) / 100
  }
  
  private var multiplier: CGFloat {
    gaugeSize / 44
  }
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(Color(white: 0.9), style: StrokeStyle(lineWidth: 8 * multiplier))
        .frame(width: gaugeSize, height: gaugeSize)
      
      Circle()
        .trim(from: progress, to: 1)
        .stroke(color, style: StrokeStyle(lineWidth: 8 * multiplier, lineCap: .butt))
        .rotationEffect(.degrees(90))
        .rotation3DEffect(.degrees(180), axis: (x: 1.0, y: 0.0, z: 0.0))
        .frame(width: gaugeSize, height: gaugeSize)
        .animation(progress == 0 ? .none : .linear(duration: 1), value: progress)
      
      Text(text ?? "\(value: percent, using: .noDecimalsFormatter)%")
        .font(.system(size: 14 * multiplier))
        .bold()
    }
  }
}

struct Gauge_Previews: PreviewProvider {
  static var previews: some View {
    Gauge()
  }
}
