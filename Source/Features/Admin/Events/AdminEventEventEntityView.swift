import Models
import Swift
import SwiftUI

struct AdminEventContentEntityView: View {
    let content: AdminEvent.Content

    var body: some View {
        switch content {
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
        case let .editSuggestion(editSuggestion):
            EditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .report(report):
            ReportEntityView(entity: report.entity)
        }
    }
}
