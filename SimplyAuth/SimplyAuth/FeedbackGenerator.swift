//
//  FeedbackGenerator.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 03/12/2020.
//

import AVFoundation
import CoreHaptics
import UIKit

struct FeedbackGenerator {
  var successFeedback: () -> Void
  var errorFeedback: () -> Void
  var selectionFeedback: () -> Void
}

// MARK: - Live implementation

extension FeedbackGenerator {
  static let live = FeedbackGenerator(
    successFeedback: {
      UINotificationFeedbackGenerator()
        .notificationOccurred(.success)
    },
    errorFeedback: {
      UINotificationFeedbackGenerator()
        .notificationOccurred(.error)
    },
    selectionFeedback: {
      UISelectionFeedbackGenerator()
        .selectionChanged()
    }
  )
}

extension FeedbackGenerator {
  static let liveDebug = FeedbackGenerator(
    successFeedback: {
      UINotificationFeedbackGenerator()
        .notificationOccurred(.success)
      print("Haptic Feedback SUCCESS")
    },
    errorFeedback: {
      UINotificationFeedbackGenerator()
        .notificationOccurred(.error)
      print("Haptic Feedback ERROR")
    },
    selectionFeedback: {
      UISelectionFeedbackGenerator()
        .selectionChanged()
      print("Haptic Feedback SELECTION")
    }
  )
}
