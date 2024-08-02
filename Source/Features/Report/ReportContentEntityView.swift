import Models
import Repositories
import SwiftUI

struct ReportContentEntityView: View {
    let content: Report.Content

    var body: some View {
        switch content {
        case let .product(product):
            ProductEntityView(product: product)
                .productCompanyLinkEnabled(true)
                .productLogoLocation(.right)
        case let .company(company):
            CompanyEntityView(company: company)
        case let .brand(brand):
            BrandEntityView(brand: brand)
        case let .subBrand(subBrand):
            SubBrandEntityView(brand: subBrand.brand, subBrand: subBrand)
        case let .comment(comment):
            CheckInCommentEntityView(comment: comment)
        case let .checkIn(checkIn):
            CheckInEntityView(checkIn: checkIn)
        case let .checkInImage(imageEntity):
            CheckInImageEntityView(imageEntity: imageEntity)
        case let .profile(profile):
            ProfileEntityView(profile: profile)
        case let .location(location):
            LocationEntityView(location: location)
        }
    }
}
