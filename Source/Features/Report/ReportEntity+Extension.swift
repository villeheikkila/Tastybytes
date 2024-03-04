import Models
import SwiftUI

public extension Report.Entity {
    var navigationTitle: LocalizedStringKey {
        switch self {
        case .product:
            "report.navigationTitle.product"
        case .company:
            "report.navigationTitle.company"
        case .brand:
            "report.navigationTitle.brand"
        case .subBrand:
            "report.navigationTitle.subBrand"
        case .checkIn:
            "report.navigationTitle.checkIn"
        case .comment:
            "report.navigationTitle.comment"
        }
    }
}

extension Report.Entity {
    @MainActor
    @ViewBuilder var view: some View {
        switch self {
        case let .product(product):
            ProductItemView(product: product, extras: [.companyLink, .logoOnLeft])
        case let .company(company):
            HStack {
                Text(company.name)
            }
        case let .brand(brand):
            HStack {
                Text(brand.name)
            }
        case let .subBrand(subBrand):
            HStack {
                Text("report.subBrand \(subBrand.name ?? "Default") from \(subBrand.brand.name)")
            }
        case let .comment(comment):
            CheckInCommentView(comment: comment)
        case let .checkIn(checkIn):
            CheckInEntityView(checkIn: checkIn)
        }
    }
}
