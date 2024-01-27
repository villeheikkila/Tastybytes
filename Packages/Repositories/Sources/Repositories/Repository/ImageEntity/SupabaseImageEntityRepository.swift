import Models
import Supabase

struct SupabaseImageEntityRepository: ImageEntityRepository {
    let client: SupabaseClient

    func getByFileName(from: ImageCategory, fileName: String) async -> Result<ImageEntity, Error> {
        do {
            let response: ImageEntity = try await client
                .database
                .from(from.table)
                .select(ImageEntity.getQuery(.saved(nil)))
                .eq("file", value: fileName)
                .limit(1)
                .single()
                .execute()
                .value

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
