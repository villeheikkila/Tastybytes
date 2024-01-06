import Models
import SwiftUI

public struct RepositoryKey: EnvironmentKey {
  public static var defaultValue: Repository = .init(
    supabaseURL: Config.supabaseUrl,
    supabaseKey: Config.supabaseAnonKey,
    headers: ["x_bundle_id": Config.bundleIdentifier, "x_app_version": Config.appVersion]
  )
}

extension EnvironmentValues {
  public var repository: Repository {
    get { self[RepositoryKey.self] }
    set { self[RepositoryKey.self] = newValue }
  }
}
