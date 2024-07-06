import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInImageAdminSheet: View {
    private let logger = Logger(category: "CheckInImageAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    let checkIn: CheckIn
    let imageEntity: ImageEntity
    let onDelete: (_ comment: ImageEntity) async -> Void

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
    }

    @ViewBuilder private var content: some View {
        Section("checkInImage.admin.section.checkIn") {
            CheckInImageEntityView(imageEntity: .init(checkIn: checkIn, imageEntity: imageEntity))
        }
        CreationInfoSection(createdBy: checkIn.profile, createdAt: imageEntity.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: imageEntity.id.formatted())
        }
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.checkInImage(imageEntity.id))))
        }
        Section {
            ConfirmedDeleteButtonView(presenting: imageEntity, action: deleteImage, description: "checkInImage.deleteAsModerator.confirmation.description", label: "checkInImage.deleteAsModerator.confirmation.label", isDisabled: false)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
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
}
