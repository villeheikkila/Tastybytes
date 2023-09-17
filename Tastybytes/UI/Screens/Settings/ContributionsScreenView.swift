import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ContributionsScreen: View {
    private let logger = Logger(category: "ContributionsScreen")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var contributions: Contributions?

    var body: some View {
        List {
            if let contributions {
                Section {
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
                } footer: {
                    Text("All your verified contributions are counted here. Verification can take some days.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Your Contributions")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadContributions(userId: profileEnvironmentModel.id)
        }
    }

    func loadContributions(userId: UUID) async {
        switch await repository.profile.getContributions(userId: userId) {
        case let .success(contributions):
            await MainActor.run {
                withAnimation {
                    self.contributions = contributions
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to load contributions. Error: \(error) (\(#file):\(#line))")
        }
    }
}
