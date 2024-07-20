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
        Section {
            switch verifiableEntity {
            case let .product(product):
                RouterLink(open: .sheet(.productAdmin(id: product.id, onDelete: {}, onUpdate: {}))) {
                    ProductEntityView(product: product)
                }
            case let .brand(brand):
                RouterLink(open: .sheet(.brandAdmin(id: brand.id, onUpdate: { _ in }, onDelete: { _ in }))) {
                    BrandEntityView(brand: brand)
                }
            case let .subBrand(subBrand):
                RouterLink(open: .sheet(.brandAdmin(id: subBrand.brand.id, onUpdate: { _ in }, onDelete: { _ in }))) {
                    SubBrandEntityView(subBrand: subBrand)
                }
            case let .company(company):
                RouterLink(open: .sheet(.companyAdmin(id: company.id, onUpdate: {}, onDelete: {}))) {
                    CompanyEntityView(company: company)
                }
            }
        }
    }
}

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
        .initialTask {
            await adminEnvironmentModel.loadUnverifiedEntities()
        }
    }
}
