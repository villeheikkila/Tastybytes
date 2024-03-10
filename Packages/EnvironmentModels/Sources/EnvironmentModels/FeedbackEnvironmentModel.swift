import SwiftUI

@MainActor
@Observable
public final class FeedbackEnvironmentModel {
    public var show = false
    public var toast = Toast(type: .complete(.black))
    public var sensoryFeedback: SensoryFeedbackEvent?

    public init() {}

    public func toggle(_ type: ToastType, disableHaptics: Bool = false) {
        switch type {
        case let .success(title):
            toast = Toast(type: .complete(.green), title: title)
            show = true
            if !disableHaptics {
                trigger(.notification(.success))
            }
        case let .warning(title):
            toast = Toast(type: .error(.red), title: title)
            show = true
        }
    }

    public func trigger(_ type: HapticType) {
        switch type {
        case let .impact(intensity):
            if let intensity {
                sensoryFeedback = intensity == .low ? SensoryFeedbackEvent(.impact(intensity: 0.3)) :
                    SensoryFeedbackEvent(.impact(intensity: 0.7))
            } else {
                sensoryFeedback = SensoryFeedbackEvent(.impact)
            }
        case let .notification(type):
            switch type {
            case .error:
                sensoryFeedback = SensoryFeedbackEvent(.error)
            case .success:
                sensoryFeedback = SensoryFeedbackEvent(.success)
            case .warning:
                sensoryFeedback = SensoryFeedbackEvent(.warning)
            }
        case .selection:
            sensoryFeedback = SensoryFeedbackEvent(.selection)
        }
    }
}

public struct SensoryFeedbackEvent: Identifiable, Equatable {
    public let id: UUID
    public let sensoryFeedback: SensoryFeedback

    init(_ sensoryFeedback: SensoryFeedback) {
        id = UUID()
        self.sensoryFeedback = sensoryFeedback
    }
}

public extension FeedbackEnvironmentModel {
    enum ErrorType {
        case unexpected, custom(String)
    }

    enum ToastType {
        case success(_ title: LocalizedStringKey)
        case warning(_ title: LocalizedStringKey)
    }

    enum FeedbackType: Int, Sendable {
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
