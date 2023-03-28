import PhotosUI
import SwiftUI

extension CompanyScreen {
  enum Sheet: Identifiable {
    var id: Self { self }
    case editSuggestionCompany
    case editCompany
    case addBrand
  }

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CompanyScreen")
    let client: Client
    @Published var company: Company
    @Published var companyJoined: Company.Joined?
    @Published var summary: Summary?
    @Published var activeSheet: Sheet?
    @Published var newCompanyNameSuggestion = ""
    @Published var showUnverifyCompanyConfirmation = false
    @Published var showDeleteCompanyConfirmationDialog = false
    @Published var selectedItem: PhotosPickerItem? {
      didSet {
        if selectedItem != nil {
          uploadCompanyImage()
        }
      }
    }

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

    func sendCompanyEditSuggestion() {}

    func editCompany() {
      guard let companyJoined else { return }
      Task {
        switch await client.company
          .update(updateRequest: Company.UpdateRequest(id: companyJoined.id, name: newCompanyNameSuggestion))
        {
        case let .success(updatedCompany):
          withAnimation {
            self.companyJoined = updatedCompany
          }
          self.activeSheet = nil
        case let .failure(error):
          logger.error("failed to edit company \(companyJoined.id): \(error.localizedDescription)")
        }
      }
    }

    func uploadCompanyImage() {
      Task {
        guard let data = await selectedItem?.getJPEG() else { return }
        switch await client.company.uploadLogo(companyId: company.id, data: data) {
        case let .success(fileName):
          company = Company(
            id: company.id,
            name: company.name,
            logoFile: fileName,
            isVerified: company.isVerified
          )
        case let .failure(error):
          logger
            .error(
              "uplodaing company logo failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func getBrandsAndSummary() async {
      Task {
        async let companyPromise = client.company.getJoinedById(id: company.id)
        async let summaryPromise = client.company.getSummaryById(id: company.id)

        switch await companyPromise {
        case let .success(company):
          self.companyJoined = company
          self.newCompanyNameSuggestion = company.name
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
