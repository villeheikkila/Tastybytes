import Models
import SwiftUI

extension AdminEvent {
    var open: Router.Open {
        switch content {
        case let .company(company):
            .sheet(.companyAdmin(id: company.id))
        case let .product(product):
            .sheet(.productAdmin(id: product.id))
        case let .subBrand(subBrand):
            .sheet(.subBrandAdmin(id: subBrand.id))
        case let .brand(brand):
            .sheet(.brandAdmin(id: brand.id))
        case let .profile(profile):
            .sheet(.profileAdmin(id: profile.id))
        case let .editSuggestion(editSuggestion):
            editSuggestion.open
        case let .report(report):
            report.content.open
        }
    }

    var sectionTitle: LocalizedStringKey {
        switch content {
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
        case let .editSuggestion(editSuggestion):
            switch editSuggestion {
            case .product:
                "admin.event.productEditSuggestionCreated.title"
            case .brand:
                "admin.event.brandEditSuggestionCreated.title"
            case .subBrand:
                "admin.event.subBrandEditSuggestionCreated.title"
            case .company:
                "admin.event.companyEditSuggestionCreated.title"
            }
        case .report:
            "admin.event.reportCreated.title"
        }
    }
}
