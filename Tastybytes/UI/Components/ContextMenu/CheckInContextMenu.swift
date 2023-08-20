import Model
import SwiftUI

extension View {
    func checkInContextMenu(
        router: Router,
        profileManager: ProfileManager,
        checkIn: CheckIn,
        onCheckInUpdate: @escaping (CheckIn) -> Void,
        onDelete: @escaping (CheckIn) -> Void
    ) -> some View {
        contextMenu {
            ControlGroup {
                CheckInShareLinkView(checkIn: checkIn)
                if checkIn.profile.id == profileManager.id {
                    RouterLink(
                        "Edit",
                        systemSymbol: .pencil,
                        sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
                            onCheckInUpdate(updatedCheckIn)
                        })
                    )
                    Button(
                        "Delete",
                        systemSymbol: .trashFill,
                        role: .destructive,
                        action: { onDelete(checkIn) }
                    )
                } else {
                    RouterLink(
                        "Check-in",
                        systemSymbol: .pencil,
                        sheet: .newCheckIn(checkIn.product, onCreation: { checkIn in
                            router.navigate(screen: .checkIn(checkIn))
                        })
                    )
                    ReportButton(entity: .checkIn(checkIn))
                }
            }
            Divider()
            RouterLink("Open Product", systemSymbol: .grid, screen: .product(checkIn.product))
            RouterLink(
                "Open Brand Owner",
                systemSymbol: .network,
                screen: .company(checkIn.product.subBrand.brand.brandOwner)
            )
            RouterLink(
                "Open Brand",
                systemSymbol: .cart,
                screen: .fetchBrand(checkIn.product.subBrand.brand)
            )
            RouterLink(
                "Open Sub-brand",
                systemSymbol: .cart,
                screen: .fetchSubBrand(checkIn.product.subBrand)
            )
            if let location = checkIn.location {
                RouterLink(
                    "Open Location",
                    systemSymbol: .network,
                    screen: .location(location)
                )
            }
            if let purchaseLocation = checkIn.purchaseLocation {
                RouterLink(
                    "Open Purchase Location",
                    systemSymbol: .network,
                    screen: .location(purchaseLocation)
                )
            }
            Divider()
        }
    }
}
