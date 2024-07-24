import Foundation
public import Tagged

public enum ImageEntity {}

public extension ImageEntity {
    typealias Id = Tagged<ImageEntity, Int>
}

public protocol ImageEntityUrl {
    var file: String { get }
    var bucket: String { get }
    var blurHash: BlurHash? { get }
}

public extension ImageEntityUrl {
    func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}

public extension ImageEntity {
    enum EntityError: Error {
        case failedToFormUrl
    }
}
