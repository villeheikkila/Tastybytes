
import Models
import SwiftUI

extension ScreenState {
    static func updateState(currentState: ScreenState, error: Error?) -> Self {
        if let error, !currentState.isPopulated {
            .error(error)
        } else {
            .populated
        }
    }

    @MainActor
    static func getState(error: Error?, withHaptics: Bool, feedbackModel: FeedbackModel) -> Self {
        withAnimation(.easeIn) {
            if let error {
                if withHaptics {
                    feedbackModel.trigger(.notification(.error))
                }
                return .error(error)
            } else {
                if withHaptics {
                    feedbackModel.trigger(.impact(intensity: .high))
                }
                return .populated
            }
        }
    }
}
