import Foundation
import Models

public protocol ImageEntityRepository: Sendable {
    func getByFileName(from: ImageCategory, fileName: String) async throws -> ImageEntity.Saved
    func getData(entity: ImageEntityProtocol) async throws -> Data
    func delete(from: ImageCategory, id: ImageEntity.Id) async throws
    func getSignedUrl(entity: ImageEntityProtocol, expiresIn: Int) async throws -> URL
}

public enum ImageCategory: String, Sendable {
    case checkInImages
    case avatars
    case logos

    var table: Database.Table {
        switch self {
        case .logos:
            .logos
        case .checkInImages:
            .checkInImages
        case .avatars:
            .profileAvatars
        }
    }
}
