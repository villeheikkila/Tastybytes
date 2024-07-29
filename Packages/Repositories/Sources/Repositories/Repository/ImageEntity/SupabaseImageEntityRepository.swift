import Models
internal import Supabase
import Foundation

struct SupabaseImageEntityRepository: ImageEntityRepository {
    let client: SupabaseClient

    func getByFileName(from: ImageCategory, fileName: String) async throws -> ImageEntity.Saved {
        try await client
            .from(from.table)
            .select(ImageEntity.getQuery(.saved(nil)))
            .eq("file", value: fileName)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(from: ImageCategory, id: ImageEntity.Id) async throws {
        try await client
            .from(from.table)
            .delete()
            .eq("id", value: id.rawValue)
            .execute()
    }

    func getData(entity: ImageEntityProtocol) async throws -> Data {
        try await client.storage
            .from(entity.bucket)
            .download(path: entity.file)
    }
}
