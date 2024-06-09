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

@MainActor
struct ScreenContentUnavailableView: View {
    @State private var isTaskRunning = false

    let errors: [Error]
    var description: LocalizedStringKey
    let action: () async -> Void

    var label: some View {
        if errors.isNetworkUnavailable() {
            Label("screen.error.networkUnavailable", systemImage: "wifi.slash")
        } else {
            Label("screen.error.unexpectedError", systemImage: "exclamationmark.triangle")
        }
    }

    var body: some View {
        ContentUnavailableView {
            label
        } description: {
            Text(description)
        } actions: {
            Button("labels.tryAgain") {
                if !isTaskRunning {
                    isTaskRunning = true
                    Task {
                        await action()
                        isTaskRunning = false
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isTaskRunning)
        }
    }
}

@MainActor
struct ScreenLoadingView: View {
    @State private var showProgressView = false

    var body: some View {
        ProgressView()
            .controlSize(.large)
            .opacity(showProgressView ? 1 : 0)
            .task {
                try? await Task.sleep(nanoseconds: 250 * 1_000_000)
                withAnimation {
                    showProgressView = true
                }
            }
    }
}

@MainActor
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
