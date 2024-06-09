import EnvironmentModels
import SwiftUI

enum ScreenState: Equatable {
    case loading
    case populated
    case error([Error])

    static func == (lhs: ScreenState, rhs: ScreenState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.populated, .populated):
            true
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.count == rhsErrors.count && lhsErrors.elementsEqual(rhsErrors, by: { $0.localizedDescription == $1.localizedDescription })
        default:
            false
        }
    }

    @MainActor
    static func getState(errors: [Error], withHaptics: Bool, feedbackEnvironmentModel: FeedbackEnvironmentModel) -> Self {
        withAnimation(.easeIn) {
            if errors.isEmpty {
                if withHaptics {
                    feedbackEnvironmentModel.trigger(.impact(intensity: .high))
                }
                return .populated
            } else {
                if withHaptics {
                    feedbackEnvironmentModel.trigger(.notification(.error))
                }
                return .error(errors)
            }
        }
    }
}
