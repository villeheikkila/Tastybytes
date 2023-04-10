import PhotosUI
import SwiftUI

extension CompanyScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CompanyScreen")
    let client: Client
    @Published var company: Company
    @Published var companyJoined: Company.Joined?
    @Published var summary: Summary?
    @Published var showUnverifyCompanyConfirmation = false
    @Published var showDeleteCompanyConfirmationDialog = false

    init(_ client: Client, company: Company) {
      self.client = client
      self.company = company
    }

    var sortedBrands: [Brand.JoinedSubBrandsProducts] {
      if let companyJoined {
        return companyJoined.brands.sorted { lhs, rhs in lhs.getNumberOfProducts() > rhs.getNumberOfProducts() }
      }
      return []
    }

    func getBrandsAndSummary() async {
      Task {
        async let companyPromise = client.company.getJoinedById(id: company.id)
        async let summaryPromise = client.company.getSummaryById(id: company.id)

        switch await companyPromise {
        case let .success(company):
          self.companyJoined = company
        case let .failure(error):
          logger.error("failed to refresh data for company '\(self.company.id)': \(error.localizedDescription)")
        }

        switch await summaryPromise {
        case let .success(summary):
          self.summary = summary
        case let .failure(error):
          logger
            .error("failed to load summary for company '\(self.company.id)' : \(error.localizedDescription)")
        }
      }
    }

    func deleteCompany(_ company: Company, onDelete: @escaping () -> Void) {
      Task {
        switch await client.company.delete(id: company.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger.error("failed to delete company '\(company.id)': \(error.localizedDescription)")
        }
      }
    }

    func verifyCompany(isVerified: Bool) {
      Task {
        switch await client.company.verification(id: company.id, isVerified: isVerified) {
        case .success:
          company = Company(id: company.id, name: company.name, logoFile: company.logoFile, isVerified: isVerified)
        case let .failure(error):
          logger
            .error("failed to verify company by id '\(self.company.id)': \(error.localizedDescription)")
        }
      }
    }
  }
}
