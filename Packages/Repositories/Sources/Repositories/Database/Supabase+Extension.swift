import Foundation
import Models
internal import Supabase

extension SupabaseClient {
    func from(_ table: Database.Table) -> PostgrestQueryBuilder {
        from(table.rawValue)
    }

    func rpc(
        fn: Database.Function,
        params: some Encodable & Sendable,
        count: CountOption? = nil
    ) throws -> PostgrestTransformBuilder {
        try rpc(fn.rawValue, params: params, count: count)
    }

    func rpc(
        fn: Database.Function,
        count: CountOption? = nil
    ) throws -> PostgrestTransformBuilder {
        try rpc(fn.rawValue, count: count)
    }
}

extension SupabaseStorageClient {
    func from(_ id: Models.Bucket) -> StorageFileApi {
        from(id.rawValue)
    }
}
