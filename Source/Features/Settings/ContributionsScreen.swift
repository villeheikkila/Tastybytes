import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
public final class ContributionsModel {
    private let logger = Logger(category: "ContributionsModel")

    public var contributions: Profile.Contributions?
    public var contributionsState: ScreenState = .loading

    private let repository: Repository
    private let id: Profile.Id

    public init(repository: Repository, id: Profile.Id) {
        self.repository = repository
        self.id = id
    }

    public func loadContributions(refresh: Bool = false) async {
        guard contributions == nil || refresh else { return }
        do {
            let contributions = try await repository.profile.getContributions(id: id)
            withAnimation {
                self.contributions = contributions
                contributionsState = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            contributionsState = .error([error])
            logger.error("Failed to load contributions. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteEditSuggestion(_ editSuggestion: EditSuggestion) async {
        do {
            try await editSuggestion.deleteSuggestion(repository: repository, editSuggestion)
            contributions = contributions?.copyWith(
                editSuggestions: contributions?.editSuggestions.removing(editSuggestion)
            )
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete an edit suggestions")
        }
    }

    public func deleteReportSuggestion(_ report: Report) async {
        do {
            try await repository.report.delete(id: report.id)
            contributions = contributions?.copyWith(reports: contributions?.reports.removing(report))
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ContributionsScreen: View {
    @Environment(Repository.self) private var repository
    let id: Profile.Id

    var body: some View {
        ContributionsInnerScreen(repository: repository, id: id)
    }
}

private struct ContributionsInnerScreen: View {
    @State private var contributionsModel: ContributionsModel

    init(repository: Repository, id: Profile.Id) {
        _contributionsModel = State(wrappedValue: ContributionsModel(repository: repository, id: id))
    }

    var body: some View {
        List {
            if let contributions = contributionsModel.contributions {
                content(contributions: contributions)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await contributionsModel.loadContributions(refresh: true)
        }
        .overlay {
            ScreenStateOverlayView(state: contributionsModel.contributionsState) {
                await contributionsModel.loadContributions()
            }
        }
        .navigationTitle("settings.contributions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await contributionsModel.loadContributions()
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
                    "report.admin.navigationTitle",
                    count: contributions.reports.count,
                    open: .screen(.profileReports(contributionsModel: contributionsModel))
                )
            }
            if !contributions.editSuggestions.isEmpty {
                RouterLink(
                    "editSuggestions.navigationTitle",
                    count: contributions.editSuggestions.count,
                    open: .screen(.profileEditSuggestions(contributionsModel: contributionsModel))
                )
            }
        }
    }
}
