import Components
import Models
import OSLog
import PhotosUI
import SwiftUI

struct EditLogoSection: View {
    private let logger = Logger(category: "EditLogoSection")
    @Environment(ProfileModel.self) private var profileModel
    @State private var showImport = false

    let logos: [ImageEntity.Saved]
    let onUpload: (Data) async -> Void
    let onDelete: (ImageEntity.Saved) async -> Void

    var body: some View {
        Section {
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
        } header: {
            HStack {
                Text("logos.edit.title")
                Spacer()
                if profileModel.hasPermission(.canAddBrandLogo) {
                    Button {
                        showImport = true
                    } label: {
                        Label("labels.add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .fileImporter(isPresented: $showImport,
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
        .customListRowBackground()
    }
}
