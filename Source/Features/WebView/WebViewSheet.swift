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

struct WebViewLink: Identifiable {
    var id: Int {
        "\(url)\(title)".hashValue
    }

    let title: String
    let url: URL
}
