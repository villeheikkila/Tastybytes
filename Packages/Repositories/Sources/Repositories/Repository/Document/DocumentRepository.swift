import Models

public protocol DocumentRepository {
    func getAboutPage() async -> Result<AboutPage, Error>
}
