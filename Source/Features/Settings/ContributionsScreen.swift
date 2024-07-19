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

    let profile: Profile

    var body: some View {
        List {
            if let contributions = profileEnvironmentModel.contributions {
                content(contributions: contributions)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await profileEnvironmentModel.loadContributions(refresh: true)
        }
        .overlay {
            ScreenStateOverlayView(state: profileEnvironmentModel.contributionsState) {
                await profileEnvironmentModel.loadContributions()
            }
        }
        .navigationTitle("settings.contributions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await profileEnvironmentModel.loadContributions()
        }
    }

    @ViewBuilder private func content(contributions: Profile.Contributions) -> some View {
        Section {
            RouterLink("products.title", count: contributions.products.count, open: .screen(.productList(products: contributions.products)))
            RouterLink("company.title", count: contributions.companies.count, open: .screen(.companyList(companies: contributions.companies)))
            RouterLink("brand.title", count: contributions.brands.count, open: .screen(.brandList(brands: contributions.brands)))
            RouterLink("subBrand.title", count: contributions.subBrands.count, open: .screen(.subBrandList(subBrands: contributions.subBrands)))
            RouterLink("barcode.title", count: contributions.barcodes.count, open: .screen(.barcodeList(barcodes: contributions.barcodes)))
        } footer: {
            Text("settings.contributions.description")
        }

        Section {
            if !contributions.reports.isEmpty {
                RouterLink(
                    "reports.title",
                    count: contributions.reports.count,
                    open: .screen(.profileReports)
                )
            }
            if !contributions.editSuggestions.isEmpty {
                RouterLink(
                    "editSuggestions.navigationTitle",
                    count: contributions.editSuggestions.count,
                    open: .screen(.profileEditSuggestions)
                )
            }
            if !contributions.duplicateSuggestions.isEmpty {
                RouterLink(
                    "duplicateSuggestions.navigationTitle",
                    count: contributions.duplicateSuggestions.count,
                    open: .screen(.profileDuplicateSuggestions)
                )
            }
        }
    }
}
