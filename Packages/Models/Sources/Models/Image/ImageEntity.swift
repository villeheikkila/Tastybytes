import Foundation
public import Tagged

public enum ImageEntity {}

public extension ImageEntity {
    typealias Id = Tagged<ImageEntity, Int>
}

public protocol ImageEntityProtocol: Sendable {
    var file: String { get }
    var bucket: String { get }
    var blurHash: BlurHash? { get }
}

public extension ImageEntityProtocol {
    var cacheKey: String { "\(bucket)-\(file)" }
}

public extension ImageEntityProtocol {
    func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}

public extension ImageEntity {
    enum EntityError: Error {
        case failedToFormUrl
    }
}
