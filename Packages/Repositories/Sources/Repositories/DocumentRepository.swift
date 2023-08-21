import Models
import Supabase

public protocol DocumentRepository {
    func getAboutPage() async -> Result<AboutPage, Error>
}

public struct SupabaseDocumentRepository: DocumentRepository {
    let client: SupabaseClient

    public func getAboutPage() async -> Result<AboutPage, Error> {
        do {
            let response: Document.About = try await client
                .database
                .from(.documents)
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
