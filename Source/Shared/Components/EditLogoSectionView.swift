import Components
import Models
import OSLog
import PhotosUI
import SwiftUI

struct EditLogoSectionView: View {
    private let logger = Logger(category: "EditLogoSection")
    @Environment(ProfileModel.self) private var profileModel
    @State private var showFileImporter = false

    let logos: [ImageEntity.Saved]
    let onUpload: (Data) async -> Void
    let onDelete: (ImageEntity.Saved) async -> Void

    var body: some View {
        Section("logos.edit.title") {
            ForEach(logos) { image in
                ImageEntityView(image: image, content: { image in
                    image.resizable()
                })
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .accessibility(hidden: true)
                .contextMenu {
                    AsyncButton("labels.delete") {
                        await onDelete(image)
                    }
                }
            }
            if profileModel.hasPermission(.canAddBrandLogo) {
                Button(action: { showFileImporter = true }) {
                    VStack(alignment: .center) {
                        Spacer()
                        Label("checkIn.image.add", systemImage: "plus")
                            .font(.system(size: 24))
                        Spacer()
                    }
                    .labelStyle(.iconOnly)
                    .frame(width: 120, height: 120)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                    .shadow(radius: 1)
                    .padding(.vertical, 1)
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.png, .jpeg])
        { result in
            switch result {
            case let .success(url):
                Task {
                    do {
                        guard url.startAccessingSecurityScopedResource() else {
                            logger.error("Failed to access the security-scoped resource")
                            return
                        }
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        let data = try Data(contentsOf: url)
                        await onUpload(data)
                    } catch {
                        logger.error("Failed to read file: \(error.localizedDescription)")
                    }
                }
            case let .failure(error):
                logger.error("File import failed: \(error.localizedDescription)")
            }
        }
        .listRowBackground(Color.clear)
    }
}
