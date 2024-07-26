import SwiftUI

struct CheckInListLoadingIndicatorView: View {
    @Binding var isLoading: Bool
    @Binding var isRefreshing: Bool

    init(isLoading: Binding<Bool>, isRefreshing: Binding<Bool> = .constant(false)) {
        _isLoading = isLoading
        _isRefreshing = isRefreshing
    }

    var body: some View {
        ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            .opacity(isLoading && !isRefreshing ? 1 : 0)
            .listRowSeparator(.hidden)
    }
}
