import SwiftUI

@MainActor
struct ScreenLoadingView: View {
    @State private var showProgressView = false

    var body: some View {
        ProgressView()
            .opacity(showProgressView ? 1 : 0)
            .task {
                try? await Task.sleep(nanoseconds: 250 * 1_000_000)
                withAnimation {
                    showProgressView = true
                }
            }
    }
}
