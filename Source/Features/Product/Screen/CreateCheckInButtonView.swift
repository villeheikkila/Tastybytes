import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CreateCheckInButtonView: View {
    @Environment(Router.self) private var router

    let product: Product.Joined
    let onCreateCheckIn: (_ checkIn: CheckIn) async -> Void

    var body: some View {
        Button(
            "checkIn.create.label.prominent",
            systemImage: "checkmark.circle",
            action: {
                router.openSheet(.checkIn(.create(product: product, onCreation: onCreateCheckIn)))
            }
        )
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .foregroundColor(.black)
        .controlSize(.regular)
    }
}
