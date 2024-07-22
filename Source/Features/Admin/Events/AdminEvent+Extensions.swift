import Models
import SwiftUI

extension AdminEvent {
    var open: Router.Open {
        switch content {
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
        case let .editSuggestion(editSuggestion):
            editSuggestion.open
        case let .report(report):
            report.entity.open
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
