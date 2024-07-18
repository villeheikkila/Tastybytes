import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class AdminEnvironmentModel {
    private let logger = Logger(category: "AdminEnvironmentModel")

    public var events = [AdminEvent]()
    public var unresolvedEventCount: Int {
        events.count
    }

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func loadAdminEventFeed() async {
        do {
            events = try await repository.admin.getAdminEventFeed()
        } catch {
            logger.error("Failed to load admin event feed")
        }
    }

    public func markAsReviewed(_ event: AdminEvent) async {
        do {
            try await repository.admin.markAdminEventAsReviewed(event: event)
            events = events.removing(event)
        } catch {
            logger.error("Failed to mark admin event as reviewed")
        }
    }
}
