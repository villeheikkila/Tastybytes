import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ContributionsScreen: View {
    private let logger = Logger(category: "ContributionsScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var alertError: AlertError?
    @State private var contributions: Contributions?

    var body: some View {
        List {
            if let contributions {
                Section {
                    HStack {
                        Text("Products")
                        Spacer()
                        Text(contributions.products.formatted())
                    }
                    HStack {
                        Text("Companies")
                        Spacer()
                        Text(contributions.companies.formatted())
                    }
                    HStack {
                        Text("Brands")
                        Spacer()
                        Text(contributions.brands.formatted())
                    }
                    HStack {
                        Text("Sub-brands")
                        Spacer()
                        Text(contributions.subBrands.formatted())
                    }
                    HStack {
                        Text("Barcodes")
                        Spacer()
                        Text(contributions.barcodes.formatted())
                    }
                } footer: {
                    Text("settings.contributions.description")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Your Contributions")
        .navigationBarTitleDisplayMode(.inline)
        .alertError($alertError)
        .task {
            await loadContributions(userId: profileEnvironmentModel.id)
        }
    }

    func loadContributions(userId: UUID) async {
        switch await repository.profile.getContributions(userId: userId) {
        case let .success(contributions):
            withAnimation {
                self.contributions = contributions
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load contributions. Error: \(error) (\(#file):\(#line))")
        }
    }
}
