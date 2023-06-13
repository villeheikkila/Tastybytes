import Supabase

protocol DocumentRepository {
    func getAboutPage() async -> Result<AboutPage, Error>
}

struct SupabaseDocumentRepository: DocumentRepository {
    let client: SupabaseClient

    func getAboutPage() async -> Result<AboutPage, Error> {
        do {
            let response: Document.About = try await client
                .database
                .from(Document.getQuery(.tableName))
                .select(columns: Document.getQuery(.saved(false)))
                .eq(column: "page_name", value: Document.Page.about.rawValue)
                .single()
                .execute()
                .value

            return .success(response.document)
        } catch {
            return .failure(error)
        }
    }
}
