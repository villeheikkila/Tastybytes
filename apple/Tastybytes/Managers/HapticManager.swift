import CoreHaptics
import SwiftUI
import UIKit

@MainActor class HapticManager: ObservableObject {
  enum HapticType {
    enum Intensity {
      case low, high
    }

    case impact(intensity: Intensity?)
    case notificaation(_ type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
  }

  private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
  private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

  init() {
    selectionFeedbackGenerator.prepare()
    impactFeedbackGenerator.prepare()
  }

  func trigger(of type: HapticType) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    switch type {
    case let .impact(intensity):
      if let intensity {
        impactFeedbackGenerator.impactOccurred(intensity: intensity == .low ? 0.3 : 0.7)
      } else {
        impactFeedbackGenerator.impactOccurred()
      }
    case let .notificaation(type):
      notificationFeedbackGenerator.notificationOccurred(type)
    case .selection:
      selectionFeedbackGenerator.selectionChanged()
    }
  }
}
