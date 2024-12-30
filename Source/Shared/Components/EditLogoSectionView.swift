import Components
import Logging
import Models
import PhotosUI
import SwiftUI

struct EditLogoSectionView: View {
    private let logger = Logger(label: "EditLogoSection")
    @Environment(ProfileModel.self) private var profileModel
    @State private var showFileImporter = false

    let logos: [Logo.Saved]
    let onAdd: (Logo.Saved) async -> Void
    let onRemove: (Logo.Saved) async -> Void

    let logoSize: Double = 128

    var body: some View {
        Section("logos.edit.title") {
            HStack(spacing: 4) {
                ForEach(logos) { image in
                    ImageEntityView(image: image, content: { image in
                        image.resizable()
                    })
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
                    .accessibility(hidden: true)
                    .contextMenu {
                        AsyncButton("labels.delete") {
                            await onRemove(image)
                        }
                    }
                }
                if profileModel.hasPermission(.canModifyLogos) {
                    RouterLink(open: .sheet(.logoPicker(onSelection: onAdd))) {
                        VStack(alignment: .center) {
                            Spacer()
                            Label("checkIn.image.add", systemImage: "plus")
                                .font(.system(size: 24))
                            Spacer()
                        }
                        .labelStyle(.iconOnly)
                        .frame(width: logoSize, height: logoSize)
                        .cardStyle()
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
    }
}
