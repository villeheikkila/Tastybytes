import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
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
                        Text("products.title")
                        Spacer()
                        Text(contributions.products.formatted())
                    }
                    HStack {
                        Text("company.title")
                        Spacer()
                        Text(contributions.companies.formatted())
                    }
                    HStack {
                        Text("brand.title")
                        Spacer()
                        Text(contributions.brands.formatted())
                    }
                    HStack {
                        Text("subBrand.title")
                        Spacer()
                        Text(contributions.subBrands.formatted())
                    }
                    HStack {
                        Text("barcode.title")
                        Spacer()
                        Text(contributions.barcodes.formatted())
                    }
                } footer: {
                    Text("settings.contributions.description")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("settings.contributions.navigationTitle")
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
