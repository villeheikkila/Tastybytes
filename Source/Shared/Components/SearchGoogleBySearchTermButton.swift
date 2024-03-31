import SwiftUI

struct SearchGoogleLink: View {
    let searchTerm: String

    private let googleUrl = URL(string: "https://www.google.com/search")

    private var url: URL? {
        guard let googleUrl else { return nil }
        return googleUrl.appending(queryItems: [URLQueryItem(name: "q", value: searchTerm)])
    }

    var body: some View {
        if let url {
            Link("searchGoogleLink.label", destination: url)
        }
    }
}
