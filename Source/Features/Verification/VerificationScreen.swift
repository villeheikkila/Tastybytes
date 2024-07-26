import Components

import SwiftUI

struct VerificationScreen: View {
    @Environment(AdminModel.self) private var adminModel

    var body: some View {
        List(adminModel.unverified) { unverifiedEntity in
            VerifiableEntityView(entity: unverifiedEntity)
                .swipeActions {
                    AsyncButton("labels.verify", systemImage: "checkmark", action: {
                        await adminModel.verifyEntity(unverifiedEntity)
                    })
                    .tint(.green)
                }
        }
        .animation(.default, value: adminModel.unverified)
        .navigationBarTitle("verification.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await adminModel.loadUnverifiedEntities()
        }
        .task {
            await adminModel.loadUnverifiedEntities()
        }
    }
}
