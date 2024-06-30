import Models
import SwiftUI

struct ScreenStateOverlayView: View {
    let state: ScreenState
    let errorDescription: LocalizedStringKey
    let errorAction: () async -> Void

    var body: some View {
        switch state {
        case let .error(errors):
            ScreenContentUnavailableView(errors: errors, description: errorDescription, action: errorAction)
        case .loading:
            ScreenLoadingView()
        case .populated:
            EmptyView()
        }
    }
}
