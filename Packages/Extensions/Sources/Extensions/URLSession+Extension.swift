import Foundation

public extension URLSession {
    // This is to silence concurrency warning
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }
}
