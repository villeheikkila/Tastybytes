import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInListCard: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Router.self) private var router
    @State private var showDeleteCheckInConfirmationDialog = false
    @State private var showDeleteConfirmationFor: CheckIn? {
        didSet {
            showDeleteCheckInConfirmationDialog = true
        }
    }

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom
    let onUpdate: @MainActor (_ checkIn: CheckIn) -> Void
    let onDelete: @MainActor (_ checkIn: CheckIn) async -> Void

    var body: some View {
        CheckInCard(checkIn: checkIn, loadedFrom: loadedFrom)
            .checkInContextMenu(
                router: router,
                profileEnvironmentModel: profileEnvironmentModel,
                checkIn: checkIn,
                onCheckInUpdate: onUpdate,
                onDelete: { checkIn in
                    showDeleteConfirmationFor = checkIn
                }
            )
            .confirmationDialog(
                "check-in.delete-confirmation.title",
                isPresented: $showDeleteCheckInConfirmationDialog,
                titleVisibility: .visible,
                presenting: showDeleteConfirmationFor
            ) { presenting in
                ProgressButton(
                    "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
                    role: .destructive,
                    action: { await onDelete(checkIn) }
                )
            }
    }
}
