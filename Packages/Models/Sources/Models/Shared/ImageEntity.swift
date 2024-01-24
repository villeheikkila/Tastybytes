import Foundation

public struct ImageEntity: Codable, Hashable, Sendable {
    public let id: Int
    public let file: String
    public let bucket: String
    
    func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}
