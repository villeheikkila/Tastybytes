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
    @State private var state: ScreenState = .loading
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
        .refreshable {
            await loadContributions(userId: profileEnvironmentModel.id)
        }
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadContributions(userId: profileEnvironmentModel.id)
            }
        }
        .navigationTitle("settings.contributions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .initialTask {
            await loadContributions(userId: profileEnvironmentModel.id)
        }
    }

    func loadContributions(userId: UUID) async {
        switch await repository.profile.getContributions(userId: userId) {
        case let .success(contributions):
            withAnimation {
                self.contributions = contributions
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load contributions. Error: \(error) (\(#file):\(#line))")
        }
    }
}
