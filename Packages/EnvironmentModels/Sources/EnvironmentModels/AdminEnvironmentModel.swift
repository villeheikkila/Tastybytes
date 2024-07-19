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

    public var roles = [Role]()

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func initialize() async {
        async let events = repository.admin.getAdminEventFeed()
        async let roles = repository.role.getRoles()
        do {
            let (events, roles) = try await (events, roles)
            self.events = events
            self.roles = roles
        } catch {
            logger.error("Failed to initialize admin environment model")
        }
    }

    public func loadAdminEventFeed() async {
        do {
            events = try await repository.admin.getAdminEventFeed()
        } catch {
            logger.error("Failed to load admin event feed")
        }
    }

    private func loadRoles() async {
        do {
            roles = try await repository.role.getRoles()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
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
