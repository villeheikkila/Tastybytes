import Models

public protocol DocumentRepository: Sendable {
    func getAboutPage() async -> Result<AboutPage, Error>
}
