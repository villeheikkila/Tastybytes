import Model
import NukeUI
import OSLog
import PhotosUI
import SwiftUI

struct CompanyScreen: View {
    private let logger = Logger(category: "CompanyScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(Router.self) private var router
    @State private var company: Company
    @State private var companyJoined: Company.Joined?
    @State private var summary: Summary?
    @State private var showUnverifyCompanyConfirmation = false
    @State private var showDeleteCompanyConfirmationDialog = false

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
                await feedbackManager.wrapWithHaptics {
                    await getBrandsAndSummary()
                }
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
        .confirmationDialog("Delete Company Confirmation",
                            isPresented: $showDeleteCompanyConfirmationDialog,
                            presenting: company)
        { presenting in
            ProgressButton("Delete \(presenting.name) Company", role: .destructive, action: {
                await deleteCompany(presenting)
            })
        }
        .task {
            if summary == nil {
                await getBrandsAndSummary()
            }
        }
    }

    @MainActor
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center, spacing: 18) {
                if let logoUrl = company.logoUrl {
                    LazyImage(url: logoUrl) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .accessibility(hidden: true)
                        } else {
                            ProgressView()
                        }
                    }
                }
                Text(company.name)
                    .font(.headline)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            navigationBarMenu
        }
    }

    private var navigationBarMenu: some View {
        Menu {
            ControlGroup {
                CompanyShareLinkView(company: company)
                if profileManager.hasPermission(.canCreateBrands) {
                    RouterLink(
                        "Brand",
                        systemSymbol: .plus,
                        sheet: .addBrand(brandOwner: company, mode: .new)
                    )
                }
                if profileManager.hasPermission(.canEditCompanies) {
                    RouterLink("Edit", systemSymbol: .pencil, sheet: .editCompany(company: company, onSuccess: {
                        await feedbackManager.wrapWithHaptics {
                            await getBrandsAndSummary()
                        }
                        feedbackManager.toggle(.success("Company updated"))
                    }))
                } else {
                    RouterLink(
                        "Edit Suggestion",
                        systemSymbol: .pencil,
                        sheet: .companyEditSuggestion(company: company, onSuccess: {
                            feedbackManager.toggle(.success("Edit suggestion sent!"))
                        })
                    )
                }
            }
            VerificationButton(isVerified: company.isVerified, verify: {
                await verifyCompany(isVerified: true)
            }, unverify: {
                showUnverifyCompanyConfirmation = true
            })
            Divider()
            ReportButton(entity: .company(company))
            if profileManager.hasPermission(.canDeleteCompanies) {
                Button(
                    "Delete",
                    systemSymbol: .trashFill,
                    role: .destructive,
                    action: { showDeleteCompanyConfirmationDialog = true }
                )
                .disabled(company.isVerified)
            }
        } label: {
            Label("Options menu", systemSymbol: .ellipsis)
                .labelStyle(.iconOnly)
        }
    }

    func getBrandsAndSummary() async {
        async let companyPromise = repository.company.getJoinedById(id: company.id)
        async let summaryPromise = repository.company.getSummaryById(id: company.id)

        switch await companyPromise {
        case let .success(company):
            companyJoined = company
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to refresh data for company. Error: \(error) (\(#file):\(#line))")
        }

        switch await summaryPromise {
        case let .success(summary):
            self.summary = summary
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to load summary for company. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCompany(_ company: Company) async {
        switch await repository.company.delete(id: company.id) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            router.reset()
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to delete company '\(company.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyCompany(isVerified: Bool) async {
        switch await repository.company.verification(id: company.id, isVerified: isVerified) {
        case .success:
            company = Company(id: company.id, name: company.name, logoFile: company.logoFile, isVerified: isVerified)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to verify company. Error: \(error) (\(#file):\(#line))")
        }
    }
}
