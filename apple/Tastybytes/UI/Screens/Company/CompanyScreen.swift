import CachedAsyncImage
import PhotosUI
import SwiftUI

struct CompanyScreen: View {
  private let logger = getLogger(category: "CompanyScreen")
  @Environment(Repository.self) private var repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) private var dismiss
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

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      HStack(alignment: .center, spacing: 18) {
        if let logoUrl = company.logoUrl {
          CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 32, height: 32)
              .accessibility(hidden: true)
          } placeholder: {
            ProgressView()
          }
        }
        Text(company.name)
          .font(.headline)
      }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      navigationBarMenu
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      VerificationButton(isVerified: company.isVerified, verify: {
        await verifyCompany(isVerified: true)
      }, unverify: {
        showUnverifyCompanyConfirmation = true
      })
      Divider()
      ShareLink("Share", item: NavigatablePath.company(id: company.id).url)
      if profileManager.hasPermission(.canCreateBrands) {
        RouterLink(
          "Add Brand",
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

  private var companyHeader: some View {
    HStack(spacing: 10) {
      if let logoUrl = company.logoUrl {
        CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 52, height: 52)
            .accessibility(hidden: true)
        } placeholder: {
          Image(systemSymbol: .photo)
            .accessibility(hidden: true)
        }
      }
      Spacer()
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
      logger.error("failed to refresh data for company: \(error.localizedDescription)")
    }

    switch await summaryPromise {
    case let .success(summary):
      self.summary = summary
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load summary for company: \(error.localizedDescription)")
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
      logger.error("failed to delete company '\(company.id)': \(error.localizedDescription)")
    }
  }

  func verifyCompany(isVerified: Bool) async {
    switch await repository.company.verification(id: company.id, isVerified: isVerified) {
    case .success:
      company = Company(id: company.id, name: company.name, logoFile: company.logoFile, isVerified: isVerified)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to verify company: \(error.localizedDescription)")
    }
  }
}
