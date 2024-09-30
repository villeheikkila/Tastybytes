import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInListCardView: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
    @State private var showDeleteConfirmation = false

    let checkIn: CheckIn.Joined
    let onUpdate: (_ checkIn: CheckIn.Joined) async -> Void
    let onDelete: (_ checkIn: CheckIn.Joined) async -> Void
    let onCreate: (_ checkIn: CheckIn.Joined) async -> Void

    var body: some View {
        CheckInView(checkIn: checkIn, onDeleteImage: { id in
            await onUpdate(checkIn.copyWith(images: checkIn.images.removingWithId(id)))
        })
        .swipeActions(edge: .trailing) {
            if checkInLoadedFrom != .product {
                RouterLink("", open: .screen(.product(checkIn.product.id)))
                    .tint(Color(.systemBackground))
            }
        }
        .swipeActions(edge: .leading) {
            RouterLink(
                "checkIn.create.label",
                systemImage: "checkmark.circle", open: .sheet(.checkIn(.create(product: checkIn.product, onCreation: onCreate)))
            )
            .tint(.green)
        }
        .contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileModel.id {
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
                open: .screen(.checkIn(checkIn.id))
            )
            RouterLink("product.screen.open", systemImage: "grid", open: .screen(.product(checkIn.product.id)))
            RouterLink(
                "company.screen.open",
                systemImage: "network",
                open: .screen(.company(checkIn.product.subBrand.brand.brandOwner.id))
            )
            RouterLink(
                "brand.screen.open",
                systemImage: "cart",
                open: .screen(.brand(checkIn.product.subBrand.brand.id))
            )
            RouterLink(
                "subBrand.screen.open",
                systemImage: "cart",
                open: .screen(.subBrand(brandId: checkIn.product.subBrand.brand.id, subBrandId: checkIn.product.subBrand.id))
            )
            if let location = checkIn.location {
                RouterLink(
                    "location.open",
                    systemImage: "network",
                    open: .screen(.location(location.id))
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "location.open.purchaseLocation",
                    systemImage: "network",
                    open: .screen(.location(purchaseLocation.id))
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
