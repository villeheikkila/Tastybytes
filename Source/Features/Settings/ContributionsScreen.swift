import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ContributionsScreen: View {
    private let logger = Logger(category: "ContributionsScreen")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var contributions: Profile.Contributions?

    let profile: Profile

    var body: some View {
        List {
            if let contributions {
                Section {
                    RouterLink(open: .screen(.productList(products: contributions.products))) {
                        LabeledContent("products.title", value: contributions.products.count.formatted())
                    }
                    RouterLink(open: .screen(.companyList(companies: contributions.companies))) {
                        LabeledContent("company.title", value: contributions.companies.count.formatted())
                    }
                    RouterLink(open: .screen(.brandList(brands: contributions.brands))) {
                        LabeledContent("brand.title", value: contributions.brands.count.formatted())
                    }
                    RouterLink(open: .screen(.subBrandList(subBrands: contributions.subBrands))) {
                        LabeledContent("subBrand.title", value: contributions.subBrands.count.formatted())
                    }
                    RouterLink(open: .screen(.barcodeList(barcodes: contributions.barcodes))) {
                        LabeledContent("barcode.title", value: contributions.barcodes.count.formatted())
                    }
                } footer: {
                    Text("settings.contributions.description")
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await loadContributions()
        }
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadContributions()
            }
        }
        .navigationTitle("settings.contributions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .initialTask {
            await loadContributions()
        }
    }

    func loadContributions() async {
        switch await repository.profile.getContributions(id: profile.id) {
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
