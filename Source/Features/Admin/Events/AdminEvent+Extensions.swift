import Models
import SwiftUI

extension AdminEvent {
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
        }
    }
}
