import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInAdminSheet: View {
    private let logger = Logger(category: "CheckInAdminSheet")
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    let checkIn: CheckIn

    var body: some View {
        Form {
            populatedContent
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("checkIn.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var populatedContent: some View {
        Section("checkIn.admin.section.checkIn") {
            RouterLink(open: .screen(.checkIn(checkIn))) {
                CheckInEntityView(checkIn: checkIn, hideHeader: true)
            }
        }

        CreationInfoSection(createdBy: checkIn.profile, createdAt: checkIn.createdAt)

        Section("admin.section.details") {
            LabeledIdView(id: checkIn.id.formatted())
        }

        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.checkIn(checkIn.id))))
        }

        Section {
            ConfirmedDeleteButtonView(presenting: checkIn, action: deleteCheckInAsModerator, description: "checkIn.delete.asModerator.title", label: "checkIn.delete.asModerator.label \(checkIn.profile.preferredName)", isDisabled: false)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func deleteCheckInAsModerator(_ checkIn: CheckIn) async {
        switch await repository.checkIn.deleteAsModerator(checkIn: checkIn) {
        case .success:
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
