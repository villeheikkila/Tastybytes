import Components

import Models
import OSLog
import PhotosUI
import SwiftUI

struct EditLogoSection: View {
    private let logger = Logger(category: "EditLogoSection")
    @Environment(AppModel.self) private var appModel
    @Environment(ProfileModel.self) private var profileModel
    @State private var selectedLogo: PhotosPickerItem?

    let logos: [ImageEntity.Saved]
    let onUpload: (Data) async -> Void
    let onDelete: (ImageEntity.Saved) async -> Void

    var body: some View {
        Section {
            ForEach(logos) { logo in
                RemoteImageView(url: logo.getLogoUrl(baseUrl: appModel.infoPlist.supabaseUrl), content: { image in
                    image.resizable()
                }, progress: {
                    ProgressView()
                })
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .accessibility(hidden: true)
                .contextMenu {
                    AsyncButton("labels.delete") {
                        await onDelete(logo)
                    }
                }
            }
        } header: {
            HStack {
                Text("logos.edit.title")
                Spacer()
                if profileModel.hasPermission(.canAddBrandLogo) {
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
