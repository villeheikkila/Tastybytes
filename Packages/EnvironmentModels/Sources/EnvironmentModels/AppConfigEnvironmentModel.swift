import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class AppConfigEnvironmentModel {
    private let logger = Logger(category: "AppConfigEnvironmentModel")
    private let repository: Repository
    public var appConfig: AppConfig?

    public init(repository: Repository) {
        self.repository = repository
    }

    public func initialize() async {
        logger.notice("Initializing app config")
        switch await repository.appConfig.get() {
        case let .success(appConfig):
            self.appConfig = appConfig
            logger.notice("App Config initialized")
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Fetching app config failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
