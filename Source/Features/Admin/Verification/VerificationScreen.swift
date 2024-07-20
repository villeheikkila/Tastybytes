import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct VerifiableEntityView: View {
    let verifiableEntity: VerifiableEntity

    var body: some View {
        switch verifiableEntity {
        case let .product(product):
            RouterLink(open: .screen(.product(product))) {
                ProductEntityView(product: product)
            }
        case let .brand(brand):
            RouterLink(open: .screen(.brand(brand))) {
                BrandEntityView(brand: brand)
            }
        case let .subBrand(subBrand):
            RouterLink(open: .screen(.brandById(id: subBrand.brand.id, initialScrollPosition: subBrand))) {
                SubBrandEntityView(subBrand: subBrand)
            }
        case let .company(company):
            RouterLink(open: .screen(.company(company))) {
                CompanyEntityView(company: company)
            }
        }
    }
}

struct VerificationScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.unverifiedEntities) { unverifiedEntity in
            VerifiableEntityView(verifiableEntity: unverifiedEntity)
                .swipeActions {
                    AsyncButton("labels.verify", systemImage: "checkmark", action: {
                        await adminEnvironmentModel.verifyEntity(unverifiedEntity)
                    })
                    .tint(.green)
                }
        }
        .animation(.default, value: adminEnvironmentModel.unverifiedEntities)
        .navigationBarTitle("verification.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await adminEnvironmentModel.loadUnverifiedEntities()
        }
        .initialTask {
            await adminEnvironmentModel.loadUnverifiedEntities()
        }
    }
}
