import Models
import Repositories
import SwiftUI

struct ReportContentView: View {
    let content: Report.Content

    var body: some View {
        switch content {
        case let .product(product):
            ProductView(product: product)
                .productCompanyLinkEnabled(true)
                .productLogoLocation(.right)
        case let .company(company):
            CompanyView(company: company)
        case let .brand(brand):
            BrandView(brand: brand)
        case let .subBrand(subBrand):
            SubBrandView(brand: subBrand.brand, subBrand: subBrand)
        case let .comment(comment):
            CheckInCommentView(comment: comment)
        case let .checkIn(checkIn):
            CheckInView(checkIn: checkIn)
                .allowsHitTesting(false)
                .checkInFooterVisibility(false)
        case let .checkInImage(imageEntity):
            CheckInImageEntityView(imageEntity: imageEntity)
        case let .profile(profile):
            ProfileView(profile: profile)
        case let .location(location):
            LocationView(location: location)
        }
    }
}
