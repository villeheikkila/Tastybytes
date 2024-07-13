import SwiftUI

struct WebViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let link: WebViewLink

    var body: some View {
        WebView(url: link.url)
            .ignoresSafeArea()
            .navigationTitle(link.title)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}
