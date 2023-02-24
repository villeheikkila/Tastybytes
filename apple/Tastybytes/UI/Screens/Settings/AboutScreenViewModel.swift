import SwiftUI

extension AboutScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "AboutScreen")
    let client: Client
    @Published var aboutPage: AboutPage?

    init(_ client: Client) {
      self.client = client
    }

    func getAboutPage() {
      Task {
        switch await client.document.getAboutPage() {
        case let .success(aboutPage):
          self.aboutPage = aboutPage
        case let .failure(error):
          logger
            .error(
              "fetching about page failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
