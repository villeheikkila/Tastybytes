import Models
internal import Supabase

struct SupabaseImageEntityRepository: ImageEntityRepository {
    let client: SupabaseClient

    func getByFileName(from: ImageCategory, fileName: String) async throws -> ImageEntity {
        try await client
            .from(from.table)
            .select(ImageEntity.getQuery(.saved(nil)))
            .eq("file", value: fileName)
            .limit(1)
            .single()
            .execute()
            .value
    }

    func delete(from: ImageCategory, entity: ImageEntity) async throws {
        try await client
            .from(from.table)
            .delete()
            .eq("id", value: entity.id.rawValue)
            .execute()
    }
}
