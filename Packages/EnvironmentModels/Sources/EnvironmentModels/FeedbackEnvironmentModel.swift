import AlertToast
import Observation
import SwiftUI

@Observable
public final class FeedbackEnvironmentModel {
    public var show = false
    public var toast = AlertToast(type: .regular, title: "")
    public var sensoryFeedback: SensoryFeedback?

    public init() {}

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
        }
    }

    public func trigger(_ type: HapticType) {
        switch type {
        case let .impact(intensity):
            if let intensity {
                sensoryFeedback = intensity == .low ? .impact(intensity: 0.3) : .impact(intensity: 0.7)
            } else {
                sensoryFeedback = .impact
            }
        case let .notification(type):
            switch type {
            case .error:
                sensoryFeedback = .error
            case .success:
                sensoryFeedback = .success
            case .warning:
                sensoryFeedback = .warning
            }
        case .selection:
            sensoryFeedback = .selection
        }
    }
}

public extension FeedbackEnvironmentModel {
    enum ErrorType {
        case unexpected, custom(String)
    }

    enum ToastType {
        case success(_ title: String)
        case warning(_ title: String)
    }

    enum FeedbackType: Int, @unchecked Sendable {
        case success = 0

        case warning = 1

        case error = 2
    }

    enum HapticType {
        public enum Intensity {
            case low, high
        }

        case impact(intensity: Intensity?)
        case notification(_ type: FeedbackType)
        case selection
    }
}
