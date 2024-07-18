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
