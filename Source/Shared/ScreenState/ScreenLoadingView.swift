import SwiftUI

struct ScreenLoadingView: View {
    @State private var showProgressView = false

    var body: some View {
        ProgressView()
            .opacity(showProgressView ? 1 : 0)
            .task {
                try? await Task.sleep(for: .milliseconds(250))
                withAnimation {
                    showProgressView = true
                }
            }
    }
}
