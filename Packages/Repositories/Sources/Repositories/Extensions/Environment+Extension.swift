import Models
import SwiftUI

public struct RepositoryKey: EnvironmentKey {
    public static var defaultValue: Repository = .init(
        supabaseURL: URL(staticString: "fill_this_in"),
        supabaseKey: "fill_this_in",
        headers: [:]
    )
}

public extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryKey.self] }
        set { self[RepositoryKey.self] = newValue }
    }
}
