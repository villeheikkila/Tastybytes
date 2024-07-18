import Foundation
import Models

public protocol AdminRepository: Sendable {
    func getAdminEventFeed() async throws -> [AdminEvent]
    func markAdminEventAsReviewed(event: AdminEvent) async throws
}
