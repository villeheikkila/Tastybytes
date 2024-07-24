import Foundation
import Models

public protocol AdminRepository: Sendable {
    func getAdminEventFeed() async throws -> [AdminEvent.Joined]
    func markAdminEventAsReviewed(id: AdminEvent.Id) async throws
}
