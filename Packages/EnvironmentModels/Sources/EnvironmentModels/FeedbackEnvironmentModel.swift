import AlertToast
import CoreHaptics
import Observation
import SwiftUI

@Observable
public final class FeedbackEnvironmentModel {
    public var show = false
    public var toast = AlertToast(type: .regular, title: "")

    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    public init() {
        selectionFeedbackGenerator.prepare()
        impactFeedbackGenerator.prepare()
    }

    public func toggle(_ type: ToastType, disableHaptics: Bool = false) {
        switch type {
        case let .success(title):
            toast = AlertToast(type: .complete(.green), title: title)
            show = true
            if !disableHaptics {
                trigger(.notification(.success))
            }
        case let .warning(title):
            toast = AlertToast(type: .error(.red), title: title)
            show = true
        case let .error(errorType):
            var title = "Unexpected error occured"
            if case let .custom(message) = errorType {
                title = message
            }

            toast = AlertToast(displayMode: .hud, type: .error(.red), title: title)
            show = true
            if !disableHaptics {
                trigger(.notification(.error))
            }
        }
    }

    public func trigger(_ type: HapticType) {
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

public extension FeedbackEnvironmentModel {
    enum ErrorType {
        case unexpected, custom(String)
    }

    enum ToastType {
        case success(_ title: String)
        case error(_ errorType: ErrorType)
        case warning(_ title: String)
    }

    enum HapticType {
        public enum Intensity {
            case low, high
        }

        case impact(intensity: Intensity?)
        case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
        case selection
    }
}
