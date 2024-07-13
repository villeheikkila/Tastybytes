import Models
internal import Supabase

struct SupabaseDocumentRepository: DocumentRepository {
    let client: SupabaseClient

    func getAboutPage() async throws -> AboutPage {
        let response: Document.About = try await client
            .from(.documents)
            .select(Document.getQuery(.saved(false)))
            .eq("page_name", value: Document.Page.about.rawValue)
            .single()
            .execute()
            .value
        return response.document
    }
}
