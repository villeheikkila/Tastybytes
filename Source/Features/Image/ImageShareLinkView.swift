import Models
import Repositories
import SwiftUI

struct ImageShareLinkView: View {
    @Environment(Repository.self) private var repository
    let image: ImageEntity.Saved
    let title: LocalizedStringKey

    private var transferable: ImageTransferable {
        ImageTransferable(image: image, repository: repository)
    }

    var body: some View {
        ShareLink(item: transferable, preview: .init(title, image: transferable))
    }
}

struct ImageTransferable: Transferable {
    let image: ImageEntityProtocol
    let repository: Repository

    private func fetchImageData() async -> Data {
        do {
            return try await repository.imageEntity.getData(entity: image)
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
