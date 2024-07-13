import Foundation
import Models

public protocol AppConfigRepository: Sendable {
    func get() async throws -> AppConfig
}
