import AlertToast
import CoreHaptics
import SwiftUI

@MainActor
final class FeedbackManager: ObservableObject {
  @Published var show = false
  @Published var toast = AlertToast(type: .regular, title: "") {
    didSet {
      show.toggle()
    }
  }

  private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
  private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

  init() {
    selectionFeedbackGenerator.prepare()
    impactFeedbackGenerator.prepare()
  }

  func toggle(_ type: ToastType, disableHaptics: Bool = false) {
    switch type {
    case let .success(title):
      toast = AlertToast(type: .complete(.green), title: title)
      if !disableHaptics {
        trigger(.notification(.success))
      }
    case let .warning(title):
      toast = AlertToast(type: .error(.red), title: title)
    case let .error(errorType):
      var title = "Unexpected error occured"
      if case let .custom(message) = errorType {
        title = message
      }

      toast = AlertToast(displayMode: .hud, type: .error(.red), title: title)
      if !disableHaptics {
        trigger(.notification(.error))
      }
    }
  }

  func wrapWithHaptics(_ asyncFunction: @escaping () async -> Void) async {
    trigger(.impact(intensity: .low))
    await asyncFunction()
    trigger(.impact(intensity: .high))
  }

  func trigger(_ type: HapticType) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    switch type {
    case let .impact(intensity):
      if let intensity {
        impactFeedbackGenerator.impactOccurred(intensity: intensity == .low ? 0.3 : 0.7)
      } else {
        impactFeedbackGenerator.impactOccurred()
      }
    case let .notification(type):
      notificationFeedbackGenerator.notificationOccurred(type)
    case .selection:
      selectionFeedbackGenerator.selectionChanged()
    }
  }
}

extension FeedbackManager {
  enum ErrorType {
    case unexpected, custom(String)
  }

  enum ToastType {
    case success(_ title: String)
    case error(_ errorType: ErrorType)
    case warning(_ title: String)
  }

  enum HapticType {
    enum Intensity {
      case low, high
    }

    case impact(intensity: Intensity?)
    case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
  }
}
