import Foundation
import Model
import PostgREST
import SupabaseStorage

extension PostgrestClient {
    func from(_ table: Database.Table) -> PostgrestQueryBuilder {
        from(table.rawValue)
    }

    func rpc(
        fn: Database.Function,
        params: some Encodable,
        count: CountOption? = nil
    ) -> PostgrestTransformBuilder {
        rpc(fn: fn.rawValue, params: params, count: count)
    }

    func rpc(
        fn: Database.Function,
        count: CountOption? = nil
    ) -> PostgrestTransformBuilder {
        rpc(fn: fn.rawValue, count: count)
    }
}

extension SupabaseStorageClient {
    func from(_ id: Database.Bucket) -> StorageFileApi {
        from(id: id.rawValue)
    }
}
