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
                    LabeledContent("products.title", value: contributions.products.formatted())
                    LabeledContent("company.title", value: contributions.companies.formatted())
                    LabeledContent("brand.title", value: contributions.brands.formatted())
                    LabeledContent("subBrand.title", value: contributions.subBrands.formatted())
                    LabeledContent("barcode.title", value: contributions.barcodes.formatted())
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
