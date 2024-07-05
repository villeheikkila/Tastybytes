import Components
import EnvironmentModels
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
        case .checkInImage:
            "report.navigationTitle.checkInImage"
        case .profile:
            "report.navigationTitle.profile"
        }
    }
}

extension Report.Entity {
    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case let .product(product):
            ProductEntityView(product: product, extras: [.companyLink, .logoOnRight])
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
            ReportCheckInImageEntityView(imageEntity: imageEntity)
        case let .profile(profile):
            ProfileEntityView(profile: profile)
        }
    }
}

struct ReportCheckInImageEntityView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let imageEntity: ImageEntity.JoinedCheckIn

    private let height = 300.0

    var body: some View {
        HStack {
            Spacer()
            if let imageUrl = imageEntity.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                RemoteImageBlurHash(url: imageUrl, blurHash: imageEntity.blurHash, height: height) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                }
            }
            Spacer()
        }
    }
}
