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
    @State private var company: Company
    @State private var companyJoined: Company.Joined?
    @State private var summary: Summary?
    @State private var showUnverifyCompanyConfirmation = false
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var alertError: AlertError?
    @State private var refreshId = 0
    @State private var resultId: Int?
    @State private var sheet: Sheet?

    init(company: Company) {
        _company = State(wrappedValue: company)
    }

    var sortedBrands: [Brand.JoinedSubBrandsProducts] {
        if let companyJoined {
            return companyJoined.brands.sorted { lhs, rhs in lhs.getNumberOfProducts() > rhs.getNumberOfProducts() }
        }
        return []
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
            Section("Brands") {
                ForEach(sortedBrands) { brand in
                    RouterLink(
                        screen: .brand(Brand.JoinedSubBrandsProductsCompany(brandOwner: company, brand: brand)),
                        asTapGesture: true
                    ) {
                        HStack {
                            Text("\(brand.name)")
                            Spacer()
                            Text("(\(brand.getNumberOfProducts()))")
                        }
                    }
                }
            }
            .headerProminence(.increased)
        }
        .listStyle(.plain)
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await getCompanyData()
            }
        #endif
            .toolbar {
                toolbarContent
            }
            .confirmationDialog("Unverify Company",
                                isPresented: $showUnverifyCompanyConfirmation,
                                presenting: company)
        { presenting in
            ProgressButton("Unverify \(presenting.name) company", action: {
                await verifyCompany(isVerified: false)
            })
        }
        .alertError($alertError)
        .confirmationDialog("Delete Company Confirmation",
                            isPresented: $showDeleteCompanyConfirmationDialog,
                            presenting: company)
        { presenting in
            ProgressButton("Delete \(presenting.name) Company", role: .destructive, action: {
                await deleteCompany(presenting)
            })
        }
        .task(id: refreshId) { [refreshId] in
            guard refreshId != resultId else { return }
            logger.info("Refreshing company screen with id: \(refreshId)")
            await getCompanyData()
            resultId = refreshId
        }
        .sheets(item: $sheet)
    }

    @MainActor
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if company.logoFile != nil {
                    CompanyLogo(company: company, size: 32)
                }
                Text(company.name)
                    .font(.headline)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            CompanyShareLinkView(company: company)
            navigationBarMenu
        }
    }

    private var navigationBarMenu: some View {
        Menu {
            ControlGroup {
                if profileEnvironmentModel.hasPermission(.canCreateBrands) {
                    RouterLink(
                        "Brand",
                        systemImage: "plus",
                        sheet: .addBrand(brandOwner: company, mode: .new),
                        useRootSheetManager: true
                    )
                }
                if profileEnvironmentModel.hasPermission(.canEditCompanies) {
                    RouterLink("Edit", systemImage: "pencil", sheet: .editCompany(company: company, onSuccess: {
                        await getCompanyData(withHaptics: true)
                        feedbackEnvironmentModel.toggle(.success("Company updated"))
                    }), useRootSheetManager: true)
                } else {
                    RouterLink(
                        "Edit Suggestion",
                        systemImage: "pencil",
                        sheet: .companyEditSuggestion(company: company, onSuccess: {
                            feedbackEnvironmentModel.toggle(.success("Edit suggestion sent!"))
                        }),
                        useRootSheetManager: true
                    )
                }
            }
            VerificationButton(isVerified: company.isVerified, verify: {
                await verifyCompany(isVerified: true)
            }, unverify: {
                showUnverifyCompanyConfirmation = true
            })
            Divider()
            ReportButton(sheet: $sheet, entity: .company(company))
            if profileEnvironmentModel.hasPermission(.canDeleteCompanies) {
                Button(
                    "Delete",
                    systemImage: "trash.fill",
                    role: .destructive,
                    action: { showDeleteCompanyConfirmationDialog = true }
                )
                .disabled(company.isVerified)
            }
        } label: {
            Label("Options menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
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
            companyJoined = company
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

    @MainActor
    func deleteCompany(_ company: Company) async {
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
            company = Company(id: company.id, name: company.name, logoFile: company.logoFile, isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }
}
