import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import SwiftUI

struct EditLogoSection: View {
    private let logger = Logger(category: "EditLogoSection")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var selectedLogo: PhotosPickerItem?

    let logos: [ImageEntity]
    let onUpload: (Data) async -> Void
    let onDelete: (ImageEntity) async -> Void

    var body: some View {
        Section {
            ForEach(logos) { logo in
                RemoteImageView(url: logo.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl), content: { image in
                    image.resizable()
                }, progress: {
                    ProgressView()
                })
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .accessibility(hidden: true)
                .contextMenu {
                    ProgressButton("labels.delete") {
                        await onDelete(logo)
                    }
                }
            }
        } header: {
            HStack {
                Text("logos.edit.title")
                Spacer()
                if profileEnvironmentModel.hasPermission(.canAddBrandLogo) {
                    PhotosPicker(
                        selection: $selectedLogo,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("labels.add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .customListRowBackground()
        .task(id: selectedLogo) { @MainActor in
            guard let selectedLogo else { return }
            guard let data = await selectedLogo.getJPEG() else {
                logger.error("Failed to convert image to JPEG")
                return
            }
            await onUpload(data)
        }
    }
}
