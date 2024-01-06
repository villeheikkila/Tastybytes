import Models
import SwiftUI

public struct RepositoryKey: EnvironmentKey {
    public static var defaultValue: Repository = .init(
        supabaseURL: Config.supabaseUrl,
        supabaseKey: Config.supabaseAnonKey,
        headers: ["X-Bundle-Identifier": Config.bundleIdentifier, "X-App-Version": Config.appVersion]
    )
}

public extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryKey.self] }
        set { self[RepositoryKey.self] = newValue }
    }
}
