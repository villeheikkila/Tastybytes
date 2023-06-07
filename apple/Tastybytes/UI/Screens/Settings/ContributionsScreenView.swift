import SwiftUI

struct ContributionsScreen: View {
  private let logger = getLogger(category: "ContributionsScreen")
  @Environment(Repository.self) private var repository
  @Environment(ProfileManager.self) private var profileManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @State private var contributions: Contributions?

  var body: some View {
    List {
      if let contributions {
        HStack {
          Text("Products")
          Spacer()
          Text(String(contributions.products))
        }
        HStack {
          Text("Companies")
          Spacer()
          Text(String(contributions.companies))
        }
        HStack {
          Text("Brands")
          Spacer()
          Text(String(contributions.brands))
        }
        HStack {
          Text("Sub-brands")
          Spacer()
          Text(String(contributions.subBrands))
        }
        HStack {
          Text("Barcodes")
          Spacer()
          Text(String(contributions.barcodes))
        }
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle("Your Contributions")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await loadContributions(userId: profileManager.id)
    }
  }

  func loadContributions(userId: UUID) async {
    switch await repository.profile.getContributions(userId: userId) {
    case let .success(contributions):
      withAnimation {
        self.contributions = contributions
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load contributions: \(error.localizedDescription)")
    }
  }
}
