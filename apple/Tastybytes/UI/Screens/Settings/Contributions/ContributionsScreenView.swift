import SwiftUI

struct ContributionsScreen: View {
  private let logger = getLogger(category: "ContributionsScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
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
    .navigationTitle("Your Contributions")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await loadContributions(userId: profileManager.getId())
    }
  }

  func loadContributions(userId: UUID) async {
    switch await repository.profile.getContributions(userId: userId) {
    case let .success(contributions):
      withAnimation {
        self.contributions = contributions
      }
    case let .failure(error):
      logger.error("failed to load contributions: \(error.localizedDescription)")
    }
  }
}
