import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct CreateCheckInButtonView: View {
    @Environment(ProfileModel.self) private var profileModel
    let product: Product.Joined
    let onCreateCheckIn: (_ checkIn: CheckIn.Joined) async -> Void

    var body: some View {
        if profileModel.hasPermission(.canCreateCheckIns) {
            RouterLink(
                "checkIn.create.label.prominent",
                open: .sheet(.checkIn(.create(product: product, onCreation: onCreateCheckIn)))
            )
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .controlSize(.large)
            .foregroundColor(.black)
            .font(.title3)
            .fontWeight(.medium)
        }
    }
}
