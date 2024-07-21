import Models
import Swift
import SwiftUI

struct AdminEventEventEntityView: View {
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
        case let .productDuplicateSuggestion(productDuplicateSuggestion):
            DuplicateProductSuggestionEntityView(duplicateProductSuggestion: productDuplicateSuggestion)
        }
    }
}
