import SwiftUI

struct ImageShareLink: View {
    let url: URL
    let title: String

    var transferable: ImageTransferable {
        ImageTransferable(url: url)
    }

    var body: some View {
        ShareLink(item: transferable, preview: .init(title, image: transferable))
    }
}

struct ImageTransferable: Codable, Transferable {
    let url: URL

    func fetchImageData() async -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
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
