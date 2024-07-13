import Foundation
import Models
internal import Supabase

struct SupabaseAppConfigRepository: AppConfigRepository {
    let client: SupabaseClient

    func get() async throws -> AppConfig {
        try await client
            .from(.appConfigs)
            .select(AppConfig.getQuery(.saved(false)))
            .limit(1)
            .single()
            .execute()
            .value
    }
}
