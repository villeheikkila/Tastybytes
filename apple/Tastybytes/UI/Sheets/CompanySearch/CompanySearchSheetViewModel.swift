import SwiftUI

extension CompanySearchSheet {
  enum Status {
    case add
    case searched
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CompanySheet")
    let client: Client
    @Published var searchText: String = ""
    @Published var searchResults = [Company]()
    @Published var status: Status?
    @Published var companyName = ""

    init(_ client: Client) {
      self.client = client
    }

    func createNew() {
      companyName = searchText
      status = Status.add
    }

    func searchCompanies() {
      Task {
        switch await client.company.search(searchTerm: searchText) {
        case let .success(searchResults):
          self.searchResults = searchResults
          self.status = Status.searched
        case let .failure(error):
          logger
            .error("failed to search companies with search term '\(self.searchText)': \(error.localizedDescription)")
        }
      }
    }

    func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) {
      let newCompany = Company.NewRequest(name: companyName)
      Task {
        switch await client.company.insert(newCompany: newCompany) {
        case let .success(newCompany):
          onSuccess(newCompany)
        case let .failure(error):
          logger.error("failed to create new company with name '\(self.companyName)': \(error.localizedDescription)")
        }
      }
    }
  }
}
