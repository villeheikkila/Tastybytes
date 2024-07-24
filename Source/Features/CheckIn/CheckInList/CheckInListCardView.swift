import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListCardView: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var showDeleteConfirmation = false

    let checkIn: CheckIn.Joined
    let onUpdate: (_ checkIn: CheckIn.Joined) async -> Void
    let onDelete: (_ checkIn: CheckIn.Joined) async -> Void
    let onCreate: (_ checkIn: CheckIn.Joined) async -> Void

    var body: some View {
        CheckInCard(checkIn: checkIn, onDeleteImage: { id in
            await onUpdate(checkIn.copyWith(images: checkIn.images.removingWithId(id)))
        })
        .contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileEnvironmentModel.id {
                    RouterLink(
                        "labels.edit",
                        systemImage: "pencil",
                        open: .sheet(.checkIn(.update(checkIn: checkIn, onUpdate: onUpdate)))
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
                    RouterLink(
                        "checkIn.title",
                        systemImage: "pencil",
                        open: .sheet(.checkIn(.create(product: checkIn.product, onCreation: onCreate)))
                    )
                }
            }
            Divider()
            RouterLink(
                "checkIn.screen.open",
                systemImage: "checkmark.circle",
                open: .screen(.checkIn(checkIn))
            )
            RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product)))
            RouterLink(
                "company.screen.open",
                systemImage: "network",
                open: .screen(.company(checkIn.product.subBrand.brand.brandOwner))
            )
            RouterLink(
                "brand.screen.open",
                systemImage: "cart",
                open: .screen(.fetchBrand(checkIn.product.subBrand.brand))
            )
            RouterLink(
                "subBrand.screen.open",
                systemImage: "cart",
                open: .screen(.subBrand(checkIn.product.subBrand))
            )
            if let location = checkIn.location {
                RouterLink(
                    "location.open",
                    systemImage: "network",
                    open: .screen(.location(location))
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "location.open.purchaseLocation",
                    systemImage: "network",
                    open: .screen(.location(purchaseLocation))
                )
            }
            Divider()
            ReportButton(entity: .checkIn(checkIn))
        }
        .confirmationDialog(
            "checkIn.delete.confirmation.title",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            presenting: checkIn
        ) { presenting in
            AsyncButton(
                "checkIn.delete.confirmation.label \(presenting.product.formatted(.fullName))",
                role: .destructive,
                action: { await onDelete(checkIn) }
            )
        }
    }
}
