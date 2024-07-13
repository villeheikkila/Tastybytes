import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInAdminSheet: View {
    private let logger = Logger(category: "CheckInAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository

    let checkIn: CheckIn
    let onDelete: () -> Void

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("checkIn.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkIn.admin.section.checkIn") {
            RouterLink(open: .screen(.checkIn(checkIn))) {
                CheckInEntityView(checkIn: checkIn, hideHeader: true)
            }
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: checkIn.profile, createdAt: checkIn.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: checkIn.id.formatted())
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.checkIn(checkIn.id))))
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(presenting: checkIn, action: deleteCheckInAsModerator, description: "checkIn.delete.asModerator.title", label: "checkIn.delete.asModerator.label \(checkIn.profile.preferredName)", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func deleteCheckInAsModerator(_ checkIn: CheckIn) async {
        do {
            try await repository.checkIn.deleteAsModerator(checkIn: checkIn)
            router.removeLast()
            onDelete()
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
