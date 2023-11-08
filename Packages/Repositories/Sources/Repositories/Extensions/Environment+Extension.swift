import Models
import SwiftUI

public struct RepositoryKey: EnvironmentKey {
    public static var defaultValue: Repository = .init(
        supabaseURL: Config.supabaseUrl,
        supabaseKey: Config.supabaseAnonKey
        
    )
}

public extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryKey.self] }
        set { self[RepositoryKey.self] = newValue }
    }
}
