import Models

public protocol ImageEntityRepository: Sendable {
    func getByFileName(from: ImageCategory, fileName: String) async -> Result<ImageEntity, Error>
}

public enum ImageCategory: String {
    case productLogos
    case brandLogos
    case checkInImages
    case companyLogos
    case avatars

    var table: Database.Table {
        switch self {
        case .brandLogos:
            .brandLogos
        case .checkInImages:
            .checkInImages
        case .productLogos:
            .productLogos
        case .companyLogos:
            .companyLogos
        case .avatars:
            .profileAvatars
        }
    }
}
