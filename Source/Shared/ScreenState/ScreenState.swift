import EnvironmentModels
import Models
import SwiftUI

extension ScreenState {
    static func updateState(currentState: ScreenState, errors: [Error]) -> Self {
        if errors.isEmpty {
            return .populated
        } else if currentState != .populated {
            return .error(errors)
        }
        return currentState
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
