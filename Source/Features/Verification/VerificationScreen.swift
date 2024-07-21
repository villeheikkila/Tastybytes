import Components
import EnvironmentModels
import SwiftUI

struct VerificationScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.unverified) { unverifiedEntity in
            VerifiableEntityView(verifiableEntity: unverifiedEntity)
                .swipeActions {
                    AsyncButton("labels.verify", systemImage: "checkmark", action: {
                        await adminEnvironmentModel.verifyEntity(unverifiedEntity)
                    })
                    .tint(.green)
                }
        }
        .animation(.default, value: adminEnvironmentModel.unverified)
        .navigationBarTitle("verification.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await adminEnvironmentModel.loadUnverifiedEntities()
        }
        .task {
            await adminEnvironmentModel.loadUnverifiedEntities()
        }
    }
}
