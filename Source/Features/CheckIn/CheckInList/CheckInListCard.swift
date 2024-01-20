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
    @State private var sheet: Sheet?
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
            .contextMenu {
                ControlGroup {
                    CheckInShareLinkView(checkIn: checkIn)
                    if checkIn.profile.id == profileEnvironmentModel.id {
                        Button(
                            "Edit",
                            systemImage: "pencil",
                            action: {
                                sheet = .checkIn(checkIn, onUpdate: { updatedCheckIn in
                                    onUpdate(updatedCheckIn)
                                })
                            }
                        )
                        Button(
                            "Delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: {
                                showDeleteConfirmationFor = checkIn
                            }
                        )
                    } else {
                        Button(
                            "Check-in",
                            systemImage: "pencil",
                            action: {
                                sheet = .newCheckIn(checkIn.product, onCreation: { checkIn in
                                    router.navigate(screen: .checkIn(checkIn))
                                })
                            }
                        )
                        ReportButton(sheet: $sheet, entity: .checkIn(checkIn))
                    }
                }
                Divider()
                RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink(
                    "Open Brand Owner",
                    systemImage: "network",
                    screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink(
                    "Open Brand",
                    systemImage: "cart",
                    screen: .fetchBrand(checkIn.product.subBrand.brand)
                )
                RouterLink(
                    "Open Sub-brand",
                    systemImage: "cart",
                    screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                if let location = checkIn.location {
                    RouterLink(
                        "Open Location",
                        systemImage: "network",
                        screen: .location(location)
                    )
                }
                if let purchaseLocation = checkIn.purchaseLocation {
                    RouterLink(
                        "Open Purchase Location",
                        systemImage: "network",
                        screen: .location(purchaseLocation)
                    )
                }
                Divider()
            }
            .sheets(item: $sheet)
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
