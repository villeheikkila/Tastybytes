import SwiftUI

struct ImageShareLinkView: View {
    let url: URL
    let title: String

    private var transferable: ImageTransferable {
        ImageTransferable(url: url)
    }

    var body: some View {
        ShareLink(item: transferable, preview: .init(title, image: transferable))
    }
}

struct ImageTransferable: Codable, Transferable {
    let url: URL

    private func fetchImageData() async -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            return Data()
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { transferable in
            await transferable.fetchImageData()
        }
    }
}
