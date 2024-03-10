import SwiftUI

@MainActor
@Observable
public final class FeedbackEnvironmentModel {
    public var toast: ToastEvent?
    public var sensoryFeedback: SensoryFeedbackEvent?

    public init() {}

    public func toggle(_ type: ToastType, disableHaptics: Bool = false) {
        switch type {
        case let .success(title):
            toast = .init(displayMode: .alert, type: .complete(.green), title: title)
            if !disableHaptics {
                trigger(.notification(.success))
            }
        case let .warning(title):
            toast = .init(displayMode: .alert, type: .error(.red), title: title)
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

public struct ToastEvent {
    public init(displayMode: ToastMode, type: ToastType, title: LocalizedStringKey? = nil, subTitle: LocalizedStringKey? = nil, duration: Double = 2, tapToDismiss: Bool = true, offsetY: CGFloat = 0, onTap: (() -> Void)? = nil) {
        self.displayMode = displayMode
        self.type = type
        self.title = title
        self.subTitle = subTitle
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.offsetY = offsetY
        self.onTap = onTap
    }

    public let displayMode: ToastMode
    public let type: ToastType
    public let title: LocalizedStringKey?
    public let subTitle: LocalizedStringKey?
    public let duration: Double
    public let tapToDismiss: Bool
    public let offsetY: CGFloat
    public let onTap: (() -> Void)?

    public enum BannerAnimation {
        case slide, pop
    }

    public enum ToastMode: Equatable {
        case alert
        case hud
        case banner(_ transition: BannerAnimation)
    }

    public enum ToastType: Equatable {
        case complete(_ color: Color)
        case error(_ color: Color)
        case systemImage(_ name: String, _ color: Color)
        case image(_ name: String, _ color: Color)
    }
}
