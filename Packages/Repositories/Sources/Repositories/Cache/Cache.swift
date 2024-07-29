import Foundation

protocol CacheProtocol: Sendable {
    func setData(key: String, data: Data) async
    func getData(key: String) async -> Data?
}
