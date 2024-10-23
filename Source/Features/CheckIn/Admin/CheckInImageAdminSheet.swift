
import Logging
import Models
import Repositories
import SwiftUI

struct CheckInImageAdminSheet: View {
    typealias OnDeleteCallback = (_ id: ImageEntity.Id) async -> Void

    enum Open {
        case report(Report.Id)
    }

    private let logger = Logger(label: "CheckInImageAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var imageDetails: ImageDetails?
    @State private var checkInImage = ImageEntity.Detailed()
    @State private var imageUrl: URL?

    let id: ImageEntity.Id
    let open: Open?
    let onDelete: OnDeleteCallback

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("checkInImage.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkInImage.admin.section.checkIn") {
            CheckInImageEntityView(imageEntity: checkInImage)
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: checkInImage.createdBy, createdAt: checkInImage.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: checkInImage.id.rawValue.formatted())
            if let imageDetails {
                LabeledContent("labels.width", value: imageDetails.size.width.formatted())
                LabeledContent("labels.height", value: imageDetails.size.height.formatted())
                LabeledContent("labels.megaBytes", value: imageDetails.fileSize.formatted(.byteCount(style: .file)))
            }
            if let imageUrl {
                Link(destination: imageUrl) {
                    Label("labels.url", systemImage: "arrow.up.forward")
                }
            }
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: checkInImage.reports.count,
                open: .screen(
                    .reports(reports: $checkInImage.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        checkInImage.copyWith(reports: reports)
                    }))
                )
            )
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(presenting: checkInImage, action: deleteImage, description: "checkInImage.deleteAsModerator.confirmation.description", label: "checkInImage.deleteAsModerator.confirmation.label", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func initialize() async {
        do {
            checkInImage = try await repository.checkIn.getDetailedCheckInImage(id: id)
            let data = try await repository.imageEntity.getData(entity: checkInImage)
            imageUrl = try await repository.imageEntity.getSignedUrl(entity: checkInImage, expiresIn: 60)
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ImageLoading", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])
            }
            let size = image.size
            let resolution = CGSize(width: image.scale * size.width, height: image.scale * size.height)
            let fileSize = data.count

            imageDetails = ImageDetails(size: size, resolution: resolution, fileSize: fileSize)
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $checkInImage.map(getter: { profile in
                            profile.reports
                        }, setter: { reports in
                            checkInImage.copyWith(reports: reports)
                        }), initialReport: id)))
                }
            }
        } catch {
            state = .error(error)
            logger.error("Failed to get image metadata'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteImage(_ imageEntity: ImageEntity.Detailed) async {
        do {
            try await repository.imageEntity.delete(from: .checkInImages, id: imageEntity.id)
            await onDelete(imageEntity.id)
            dismiss()
        } catch {
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
