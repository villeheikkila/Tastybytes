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
            Section {
                AdminEventEntityView(event: event.event)
            } header: {
                Text(event.sectionTitle)
            } footer: {
                Text(event.createdAt.formatted())
            }
            .contentShape(.rect)
            .onTapGesture {
                open(event: event)
            }
            .swipeActions {
                AsyncButton("labels.ok", systemImage: "checkmark") {
                    await adminEnvironmentModel.markAsReviewed(event)
                }
                .tint(.green)
            }
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

    func open(event: AdminEvent) {
        switch event.event {
        case let .company(company):
            router.open(.screen(.company(company)))
        case let .product(product):
            router.open(.screen(.product(product)))
        case let .subBrand(subBrand):
            router.fetchAndNavigateTo(repository, .brand(id: subBrand.brand.id))
        case let .brand(brand):
            router.fetchAndNavigateTo(repository, .brand(id: brand.id))
        case let .profile(profile):
            router.open(.screen(.profile(profile)))
        case let .productEditSuggestion(editSuggestion):
            router.open(.screen(.product(editSuggestion.product)))
        case let .brandEditSuggestion(editSuggestion):
            router.fetchAndNavigateTo(repository, .brand(id: editSuggestion.id))
        case let .subBrandEditSuggestion(editSuggestion):
            router.fetchAndNavigateTo(repository, .brand(id: editSuggestion.subBrand.brand.id))
        case let .companyEditSuggestion(editSuggestion):
            router.open(.screen(.company(editSuggestion.company)))
        case let .report(report):
            report.entity.open(repository, router)
        }
    }
}

struct AdminEventEntityView: View {
    let event: AdminEvent.Event

    var body: some View {
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
        }
    }
}

extension AdminEvent {
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
        }
    }
}

struct SubBrandEditSuggestionEntityView: View {
    let editSuggestion: SubBrand.EditSuggestion

    var body: some View {
        VStack {
            if let name = editSuggestion.name {
                Text(name)
            }
        }
    }
}

struct ProductEditSuggestionEntityView: View {
    let editSuggestion: Product.EditSuggestion

    var body: some View {
        Text(editSuggestion.id.formatted())
    }
}
