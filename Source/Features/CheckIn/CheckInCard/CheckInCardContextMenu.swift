import Components
import EnvironmentModels
import Extensions
import Models
import SwiftUI

extension View {
    func checkInContextMenu(
        router: Router,
        profileEnvironmentModel: ProfileEnvironmentModel,
        checkIn: CheckIn,
        onCheckInUpdate: @escaping (CheckIn) -> Void,
        onDelete: @escaping (CheckIn) -> Void
    ) -> some View {
        contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileEnvironmentModel.id {
                    RouterLink(
                        "Edit",
                        systemImage: "pencil",
                        sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                            onCheckInUpdate(updatedCheckIn)
                        })
                    )
                    Button(
                        "Delete",
                        systemImage: "trash.fill",
                        role: .destructive,
                        action: { onDelete(checkIn) }
                    )
                } else {
                    RouterLink(
                        "Check-in",
                        systemImage: "pencil",
                        sheet: .newCheckIn(checkIn.product, onCreation: {@MainActor checkIn in
                            router.navigate(screen: .checkIn(checkIn))
                        })
                    )
                    ReportButton(entity: .checkIn(checkIn))
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
    }
}
