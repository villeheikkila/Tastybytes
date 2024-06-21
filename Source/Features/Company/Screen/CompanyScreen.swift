import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct CompanyScreen: View {
    private let logger = Logger(category: "CompanyScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
    @State private var company: Company.Joined
    @State private var summary: Summary?
    @State private var showUnverifyCompanyConfirmation = false
    @State private var showDeleteCompanyConfirmationDialog = false

    init(company: Company) {
        _company = State(wrappedValue: .init(company: company))
    }

    var sortedBrands: [Brand.JoinedSubBrandsProducts] {
        company.brands.sorted { lhs, rhs in lhs.productCount > rhs.productCount }
    }

    var body: some View {
        List {
            if state == .populated {
                populatedContent
            }
        }
        .listStyle(.plain)
        .refreshable {
            await getCompanyData(withHaptics: true)
        }
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "company.screen.failedToLoad \(company.name)") {
                await getCompanyData(withHaptics: true)
            }
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
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

    @ViewBuilder private var populatedContent: some View {
        if let summary, summary.averageRating != nil {
            Section {
                SummaryView(summary: summary)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        Section("brand.title") {
            ForEach(sortedBrands) { brand in
                RouterLink(
                    screen: .brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: company.saved, brand: brand))
                ) {
                    CompanyBrandRow(brand: brand)
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
                CompanyShareLinkView(company: company.saved)
                if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                    Button(
                        "brand.title",
                        systemImage: "plus",
                        action: { router.openRootSheet(.addBrand(brandOwner: company.saved, mode: .new)) }
                    )
                }
                if profileEnvironmentModel.hasPermission(.canEditCompanies) {
                    Button("labels.edit", systemImage: "pencil", action: { router.openRootSheet(.editCompany(company: company.saved, onSuccess: {
                        await getCompanyData(withHaptics: true)
                        feedbackEnvironmentModel.toggle(.success("company.update.success.toast"))
                    })) })
                } else {
                    Button(
                        "company.editSuggestion.title",
                        systemImage: "pencil",
                        action: { router.openRootSheet(.companyEditSuggestion(company: company.saved, onSuccess: {
                            feedbackEnvironmentModel.toggle(.success("company.editSuggestion.success.toast"))
                        })) }
                    )
                }
            }
            VerificationButton(isVerified: company.isVerified, verify: {
                await verifyCompany(isVerified: true)
            }, unverify: {
                showUnverifyCompanyConfirmation = true
            })
            Divider()
            ReportButton(entity: .company(company.saved))
            if profileEnvironmentModel.hasPermission(.canDeleteCompanies) {
                Button(
                    "labels.delete",
                    systemImage: "trash.fill",
                    role: .destructive,
                    action: { showDeleteCompanyConfirmationDialog = true }
                )
                .disabled(company.isVerified)
            }
        } label: {
            Label("labels.menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
        }
        .confirmationDialog("company.unverify.confirmationDialog.title",
                            isPresented: $showUnverifyCompanyConfirmation,
                            presenting: company)
        { presenting in
            ProgressButton("company.unverify.confirmationDialog.label \(presenting.name)", action: {
                await verifyCompany(isVerified: false)
            })
        }
        .confirmationDialog("company.delete.confirmationDialog.title",
                            isPresented: $showDeleteCompanyConfirmationDialog,
                            presenting: company)
        { presenting in
            ProgressButton("company.delete.confirmationDialog.label \(presenting.name)", role: .destructive, action: {
                await deleteCompany(presenting)
            })
        }
    }

    func getCompanyData(withHaptics: Bool = false) async {
        async let companyPromise = repository.company.getJoinedById(id: company.id)
        async let summaryPromise = repository.company.getSummaryById(id: company.id)

        let (companyResult, summaryResult) = await (
            companyPromise,
            summaryPromise
        )

        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }

        var errors = [Error]()
        switch companyResult {
        case let .success(company):
            self.company = company
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to refresh data for company. Error: \(error) (\(#file):\(#line))")
        }

        switch summaryResult {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.isCancelled else { return }
            errors.append(error)
            logger.error("Failed to load summary for company. Error: \(error) (\(#file):\(#line))")
        }

        state = .getState(errors: errors, withHaptics: withHaptics, feedbackEnvironmentModel: feedbackEnvironmentModel)
    }

    func deleteCompany(_ company: Company.Joined) async {
        switch await repository.company.delete(id: company.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.reset()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(isVerified: Bool) async {
        switch await repository.company.verification(id: company.id, isVerified: isVerified) {
        case .success:
            company = company.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }
}
