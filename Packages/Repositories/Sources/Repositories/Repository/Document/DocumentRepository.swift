import Models

public protocol DocumentRepository: Sendable {
    func getAboutPage() async throws -> Document.About.Page
}
