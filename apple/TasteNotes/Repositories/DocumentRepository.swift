import Foundation
import Supabase

protocol DocumentRepository {
    func getAboutPage() async -> Result<AboutPage, Error>
}

struct SupabaseDocumentRepository: DocumentRepository {
    let client: SupabaseClient

    func getAboutPage() async -> Result<AboutPage, Error> {
        do {
            let response = try await client
                .database
                .from(Document.getQuery(.tableName))
                .select(columns: Document.getQuery(.saved(false)))
                .single()
                .execute()
                .decoded(to: Document.About.self)

            return .success(response.document)
        } catch {
            return .failure(error)
        }
    }
}
