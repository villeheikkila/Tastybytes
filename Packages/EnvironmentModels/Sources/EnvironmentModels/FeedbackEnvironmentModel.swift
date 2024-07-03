import SwiftUI

@MainActor
@Observable
public final class FeedbackEnvironmentModel {
    public var sensoryFeedback: SensoryFeedbackEvent?

    public init() {}

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

public struct ToastEvent: Equatable {
    public init(type: ToastType, title: LocalizedStringKey? = nil, subTitle: LocalizedStringKey? = nil, duration: Double = 2, tapToDismiss: Bool = true, offsetY: CGFloat = 0) {
        self.type = type
        self.title = title
        self.subTitle = subTitle
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.offsetY = offsetY
    }

    public let type: ToastType
    public let title: LocalizedStringKey?
    public let subTitle: LocalizedStringKey?
    public let duration: Double
    public let tapToDismiss: Bool
    public let offsetY: CGFloat

    public enum ToastType: Equatable {
        case complete(_ color: Color)
        case error(_ color: Color)
        case systemImage(_ name: String, _ color: Color)
        case image(_ name: String, _ color: Color)
    }
}
