import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInImageAdminSheet: View {
    private let logger = Logger(category: "CheckInImageAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var imageDetails: ImageDetails?

    let checkIn: CheckIn
    let imageEntity: ImageEntity
    let onDelete: (_ comment: ImageEntity) async -> Void

    private var imageUrl: URL? {
        imageEntity.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)
    }

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("checkInImage.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await loadImageAndDetails()
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkInImage.admin.section.checkIn") {
            CheckInImageEntityView(imageEntity: .init(checkIn: checkIn, imageEntity: imageEntity))
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: checkIn.profile, createdAt: imageEntity.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: imageEntity.id.formatted())
            if let imageDetails {
                LabeledContent("labels.width", value: imageDetails.size.width.formatted())
                LabeledContent("labels.height", value: imageDetails.size.height.formatted())
                LabeledContent("labels.megaBytes", value: imageDetails.fileSize.formatted(.byteCount(style: .file)))
            }
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.checkInImage(imageEntity.id))))
            if let imageUrl {
                Link(destination: imageUrl) {
                    Label("labels.url", systemImage: "arrow.up.forward")
                }
            }
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(presenting: imageEntity, action: deleteImage, description: "checkInImage.deleteAsModerator.confirmation.description", label: "checkInImage.deleteAsModerator.confirmation.label", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func loadImageAndDetails() async {
        guard let imageUrl else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)

            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ImageLoading", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])
            }

            let size = image.size
            let resolution = CGSize(width: image.scale * size.width, height: image.scale * size.height)
            let fileSize = data.count

            imageDetails = ImageDetails(size: size, resolution: resolution, fileSize: fileSize)

        } catch {
            logger.error("Failed to get image metadata'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteImage(_ imageEntity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .checkInImages, entity: imageEntity) {
        case .success:
            await onDelete(imageEntity)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image'. Error: \(error) (\(#file):\(#line))")
        }
    }

    struct ImageDetails {
        let size: CGSize
        let resolution: CGSize
        let fileSize: Int
    }
}
