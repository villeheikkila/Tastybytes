import SwiftUI

struct CheckInListLoadingIndicator: View {
    @Binding var isLoading: Bool
    @Binding var isRefreshing: Bool

    var body: some View {
        ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            .opacity(isLoading && !isRefreshing ? 1 : 0)
        #if !os(watchOS)
            .listRowSeparator(.hidden)
        #endif
    }
}
