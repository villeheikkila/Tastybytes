import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CompanyScreen: View {
    private let logger = Logger(category: "CompanyScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
    @State private var company: Company.Joined
    @State private var summary: Summary?

    init(company: any CompanyProtocol) {
        _company = State(wrappedValue: .init(company: company))
    }

    var sortedBrands: [Brand.JoinedSubBrandsProducts] {
        company.brands.sorted { lhs, rhs in lhs.productCount > rhs.productCount }
    }

    var body: some View {
        List {
            if state == .populated {
                content
            }
        }
        .listStyle(.plain)
        .refreshable {
            await getCompanyData(withHaptics: true)
        }
        .overlay {
            if state == .populated, company.brands.isEmpty {
                ContentUnavailableView("company.screen.empty.title", systemImage: "tray")
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "company.screen.failedToLoad \(company.name)") {
                    await getCompanyData(withHaptics: true)
                }
            }
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await getCompanyData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if !company.logos.isEmpty {
                    CompanyLogo(company: company, size: 32)
                }
                Text(company.name)
                    .font(.headline)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            navigationBarMenu
        }
    }

    @ViewBuilder private var content: some View {
        if let summary, summary.averageRating != nil {
            SummaryView(summary: summary)
        }
        if !sortedBrands.isEmpty {
            Section("brand.title") {
                ForEach(sortedBrands) { brand in
                    RouterLink(
                        open: .screen(.brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: company.saved, brand: brand))
                        )) {
                            CompanyBrandRow(brand: brand)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            0
                        }
                }
            }
            .headerProminence(.increased)
        }
    }

    private var navigationBarMenu: some View {
        Menu {
            ControlGroup {
                CompanyShareLinkView(company: company.saved)
                if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                    RouterLink(
                        "brand.title",
                        systemImage: "plus",
                        open: .sheet(.addBrand(brandOwner: company.saved, mode: .new(onCreate: { brand in
                            withAnimation {
                                company = company.copyWith(brands: company.brands + [.init(newBrand: brand)])
                            }
                        })))
                    )
                }
            }
            Divider()
            RouterLink(
                "company.editSuggestion.title",
                systemImage: "pencil",
                open: .sheet(.companyEditSuggestion(company: company.saved, onSuccess: {
                    router.open(.toast(.success("company.editSuggestion.success.toast")))
                }))
            )
            ReportButton(entity: .company(company.saved))
            Divider()
            AdminRouterLink(open: .sheet(.companyAdmin(company: company.saved, onUpdate: {
                await getCompanyData(withHaptics: true)
                router.open(.toast(.success("company.update.success.toast")))
            }, onDelete: {
                router.removeLast()
            })))
        } label: {
            Label("labels.menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
        }
    }

    private func getCompanyData(withHaptics: Bool = false) async {
        async let companyPromise = repository.company.getJoinedById(id: company.id)
        async let summaryPromise = repository.company.getSummaryById(id: company.id)
        var errors = [Error]()
        do {
            let (companyResult, summaryResult) = try await (
                companyPromise,
                summaryPromise
            )
            withAnimation {
                company = companyResult
                summary = summaryResult
            }
        } catch {
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to refresh data for company. Error: \(error) (\(#file):\(#line))")
        }
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        state = .getState(errors: errors, withHaptics: withHaptics, feedbackEnvironmentModel: feedbackEnvironmentModel)
    }
}
