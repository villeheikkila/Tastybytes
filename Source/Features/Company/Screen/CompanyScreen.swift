import Components

import Extensions
import Logging
import Models
import PhotosUI
import Repositories
import SwiftUI

struct CompanyScreen: View {
    private let logger = Logger(label: "CompanyScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
    @State private var company = Company.Saved()
    @State private var brands = [Brand.Saved]()
    @State private var summary: Summary?

    let id: Company.Id

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .animation(.default, value: brands)
        .refreshable {
            await getCompanyData(withHaptics: true)
        }
        .overlay {
            if state.isPopulated, brands.isEmpty {
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
            if state.isPopulated {
                toolbarContent
            }
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
        Section("brand.title") {
            ForEach(brands) { brand in
                RouterLink(open: .screen(.brand(brand.id))) {
                    CompanyBrandRowView(brand: brand)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    0
                }
            }
        }
        .headerProminence(.increased)
    }

    private var navigationBarMenu: some View {
        Menu {
            ControlGroup {
                CompanyShareLinkView(company: company)
                if profileModel.hasPermission(.canCreateBrands) {
                    RouterLink(
                        "brand.title",
                        systemImage: "plus",
                        open: .sheet(.brandPicker(brandOwner: company, brand: .constant(nil), mode: .new(onCreate: { brand in
                            brands = brands + [.init(brand: brand)]
                        })))
                    )
                }
            }
            Divider()
            RouterLink(
                "labels.editSuggestion",
                systemImage: "pencil",
                open: .sheet(.companyEditSuggestion(company: company, onSuccess: {
                    router.open(.toast(.success("company.editSuggestion.success.toast")))
                }))
            )
            ReportButton(entity: .company(company))
            Divider()
            AdminRouterLink(open: .sheet(.companyAdmin(id: id, onUpdate: { _ in
                await getCompanyData(withHaptics: true)
                router.open(.toast(.success("company.update.success.toast")))
            }, onDelete: { _ in
                router.removeLast()
            })))
        } label: {
            Label("labels.menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
        }
    }

    private func getCompanyData(withHaptics: Bool = false) async {
        async let companyPromise = repository.company.getById(id: id)
        async let brandsPromise = repository.brand.getBrandsWithProductCount(id: id)
        async let summaryPromise = repository.company.getSummaryById(id: id)
        do {
            let (company, brands, summary) = try await (
                companyPromise,
                brandsPromise,
                summaryPromise
            )
            withAnimation {
                self.company = company
                self.brands = brands
                self.summary = summary
                state = .populated
            }
            if withHaptics {
                feedbackModel.trigger(.impact(intensity: .low))
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .getState(error: error, withHaptics: withHaptics, feedbackModel: feedbackModel)
            logger.error("Failed to refresh data for company. Error: \(error) (\(#file):\(#line))")
        }
    }
}
