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
        }
    }
}

extension Report.Entity {
    @MainActor
    @ViewBuilder var view: some View {
        switch self {
        case let .product(product):
            ProductItemView(product: product, extras: [.companyLink, .logoOnRight])
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
        case let .checkInImage(imageEntity):
            ReportCheckInImageEntityView(imageEntity: imageEntity)
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
