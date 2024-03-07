import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInListCard: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Router.self) private var router
    @State private var showDeleteConfirmation = false

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom
    let onUpdate: @MainActor (_ checkIn: CheckIn) -> Void
    let onDelete: @MainActor (_ checkIn: CheckIn) async -> Void
    let onCreate: @MainActor (_ checkIn: CheckIn) -> Void

    @Binding var sheet: Sheet?

    var body: some View {
        CheckInCard(checkIn: checkIn, loadedFrom: loadedFrom)
            .contextMenu {
                ControlGroup {
                    CheckInShareLinkView(checkIn: checkIn)
                    if checkIn.profile.id == profileEnvironmentModel.id {
                        Button(
                            "labels.edit",
                            systemImage: "pencil",
                            action: {
                                sheet = .checkIn(checkIn, onUpdate: { updatedCheckIn in
                                    onUpdate(updatedCheckIn)
                                })
                            }
                        )
                        Button(
                            "labels.delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: {
                                showDeleteConfirmation = true
                            }
                        )
                    } else {
                        Button(
                            "checkIn.title",
                            systemImage: "pencil",
                            action: {
                                sheet = .newCheckIn(checkIn.product, onCreation: onCreate)
                            }
                        )
                        ReportButton(sheet: $sheet, entity: .checkIn(checkIn))
                    }
                }
                if let firstImage = checkIn.images.first, let imageUrl = firstImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                    ImageShareLink(url: imageUrl)
                }
                Divider()
                RouterLink("product.screen.open", systemImage: "grid", screen: .product(checkIn.product))
                RouterLink(
                    "company.screen.open",
                    systemImage: "network",
                    screen: .company(checkIn.product.subBrand.brand.brandOwner)
                )
                RouterLink(
                    "brand.screen.open",
                    systemImage: "cart",
                    screen: .fetchBrand(checkIn.product.subBrand.brand)
                )
                RouterLink(
                    "subBrand.screen.open",
                    systemImage: "cart",
                    screen: .fetchSubBrand(checkIn.product.subBrand)
                )
                if let location = checkIn.location {
                    RouterLink(
                        "location.open",
                        systemImage: "network",
                        screen: .location(location)
                    )
                }
                if let purchaseLocation = checkIn.purchaseLocation {
                    RouterLink(
                        "location.open.purchaseLocation",
                        systemImage: "network",
                        screen: .location(purchaseLocation)
                    )
                }
                Divider()
            }
            .confirmationDialog(
                "checkIn.delete.confirmation.title",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible,
                presenting: checkIn
            ) { presenting in
                ProgressButton(
                    "checkIn.delete.confirmation.label \(presenting.product.formatted(.fullName))",
                    role: .destructive,
                    action: { await onDelete(checkIn) }
                )
            }
    }
}
