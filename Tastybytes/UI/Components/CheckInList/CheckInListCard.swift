import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

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
    let onUpdate: (_ checkIn: CheckIn) -> Void
    let onDelete: (_ checkIn: CheckIn) async -> Void

    var body: some View {
        CheckInCard(checkIn: checkIn, loadedFrom: .activity(profileEnvironmentModel.profile))
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
                "Are you sure you want to delete check-in? The data will be permanently lost.",
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
