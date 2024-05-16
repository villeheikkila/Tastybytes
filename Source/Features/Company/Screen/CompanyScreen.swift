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
    @State private var company: Company.Joined
    @State private var summary: Summary?
    @State private var showUnverifyCompanyConfirmation = false
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var alertError: AlertError?
    @State private var sheet: Sheet?

    init(company: Company) {
        _company = State(wrappedValue: .init(company: company))
    }

    var sortedBrands: [Brand.JoinedSubBrandsProducts] {
        company.brands.sorted { lhs, rhs in lhs.productCount > rhs.productCount }
    }

    var body: some View {
        List {
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
        .listStyle(.plain)
        .refreshable {
            await getCompanyData(withHaptics: true)
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheets(item: $sheet)
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

    private var navigationBarMenu: some View {
        Menu {
            ControlGroup {
                CompanyShareLinkView(company: company.saved)
                if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                    Button(
                        "brand.title",
                        systemImage: "plus",
                        action: { sheet = .addBrand(brandOwner: company.saved, mode: .new) }
                    )
                }
                if profileEnvironmentModel.hasPermission(.canEditCompanies) {
                    Button("labels.edit", systemImage: "pencil", action: { sheet = .editCompany(company: company.saved, onSuccess: {
                        await getCompanyData(withHaptics: true)
                        feedbackEnvironmentModel.toggle(.success("company.update.success.toast"))
                    }) })
                } else {
                    Button(
                        "company.editSuggestion.title",
                        systemImage: "pencil",
                        action: { sheet = .companyEditSuggestion(company: company.saved, onSuccess: {
                            feedbackEnvironmentModel.toggle(.success("company.editSuggestion.success.toast"))
                        }) }
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
        .alertError($alertError)
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
        switch companyResult {
        case let .success(company):
            self.company = company
            if withHaptics {
                feedbackEnvironmentModel.trigger(.impact(intensity: .high))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to refresh data for company. Error: \(error) (\(#file):\(#line))")
        }

        switch summaryResult {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load summary for company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCompany(_ company: Company.Joined) async {
        switch await repository.company.delete(id: company.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.reset()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(isVerified: Bool) async {
        switch await repository.company.verification(id: company.id, isVerified: isVerified) {
        case .success:
            company = company.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }
}
