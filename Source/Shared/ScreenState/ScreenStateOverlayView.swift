import Models
import SwiftUI

struct ScreenStateOverlayView: View {
    let state: ScreenState
    let errorDescription: LocalizedStringKey?
    let errorAction: () async -> Void

    init(state: ScreenState, errorDescription: LocalizedStringKey? = nil, errorAction: @escaping () async -> Void) {
        self.state = state
        self.errorDescription = errorDescription
        self.errorAction = errorAction
    }

    var body: some View {
        switch state {
        case let .error(error):
            ScreenContentUnavailableView(error: error, description: errorDescription, action: errorAction)
        case .loading:
            ScreenLoadingView()
        case .populated:
            EmptyView()
        }
    }
}
