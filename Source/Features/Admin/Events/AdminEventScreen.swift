import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct AdminEventScreen: View {
    let logger = Logger(category: "AdminEventScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.events) { event in
            AdminEventRowView(event: event)
        }
        .refreshable {
            await adminEnvironmentModel.loadAdminEventFeed()
        }
        .animation(.default, value: adminEnvironmentModel.events)
        .navigationTitle("admin.events.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await adminEnvironmentModel.loadAdminEventFeed()
        }
    }
}

struct AdminEventRowView: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel
    let event: AdminEvent

    var body: some View {
        Section {
            RouterLink(open: event.open) {
                event.view
            }
            .buttonStyle(.plain)
        } header: {
            Text(event.sectionTitle)
        } footer: {
            Text(event.createdAt.formatted())
        }
        .contentShape(.rect)
        .swipeActions {
            AsyncButton("labels.ok", systemImage: "checkmark") {
                await adminEnvironmentModel.markAsReviewed(event)
            }
            .tint(.green)
        }
    }
}

extension AdminEvent {
    @MainActor
    @ViewBuilder
    var view: some View {
        switch event {
        case let .company(company):
            CompanyEntityView(company: company)
        case let .product(product):
            ProductEntityView(product: product)
        case let .subBrand(subBrand):
            SubBrandEntityView(subBrand: subBrand)
        case let .brand(brand):
            BrandEntityView(brand: brand)
        case let .profile(profile):
            ProfileEntityView(profile: profile)
        case let .productEditSuggestion(editSuggestion):
            ProductEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .brandEditSuggestion(editSuggestion):
            BrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .subBrandEditSuggestion(editSuggestion):
            SubBrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .companyEditSuggestion(editSuggestion):
            CompanyEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .report(report):
            ReportEntityView(entity: report.entity)
        case let .productDuplicateSuggestion(productDuplicateSuggestion):
            DuplicateProductSuggestionEntityView(duplicateProductSuggestion: productDuplicateSuggestion)
        }
    }

    var open: Router.Open {
        switch event {
        case let .company(company):
            .screen(.company(company))
        case let .product(product):
            .screen(.product(product))
        case let .subBrand(subBrand):
            .navigatablePath(.brand(id: subBrand.brand.id))
        case let .brand(brand):
            .navigatablePath(.brand(id: brand.id))
        case let .profile(profile):
            .screen(.profile(profile))
        case let .productEditSuggestion(editSuggestion):
            .screen(.product(editSuggestion.product))
        case let .brandEditSuggestion(editSuggestion):
            .navigatablePath(.brand(id: editSuggestion.brand.id))
        case let .subBrandEditSuggestion(editSuggestion):
            .navigatablePath(.brand(id: editSuggestion.subBrand.brand.id))
        case let .companyEditSuggestion(editSuggestion):
            .screen(.company(editSuggestion.company))
        case let .report(report):
            report.entity.open
        case let .productDuplicateSuggestion(duplicateProductSuggestion):
            .screen(.product(duplicateProductSuggestion.product))
        }
    }

    var sectionTitle: LocalizedStringKey {
        switch event {
        case .company:
            "admin.event.companyCreated.title"
        case .product:
            "admin.event.productCreated.title"
        case .subBrand:
            "admin.event.subBrandCreated.title"
        case .brand:
            "admin.event.brandCreated.title"
        case .profile:
            "admin.event.profileCreated.title"
        case .productEditSuggestion:
            "admin.event.productEditSuggestionCreated.title"
        case .brandEditSuggestion:
            "admin.event.brandEditSuggestionCreated.title"
        case .subBrandEditSuggestion:
            "admin.event.subBrandEditSuggestionCreated.title"
        case .companyEditSuggestion:
            "admin.event.companyEditSuggestionCreated.title"
        case .report:
            "admin.event.reportCreated.title"
        case .productDuplicateSuggestion:
            "admin.event.productDuplicateSuggestionCreated.title"
        }
    }
}
