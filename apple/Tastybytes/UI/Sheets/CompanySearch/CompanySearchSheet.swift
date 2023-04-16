import SwiftUI

struct CompanySearchSheet: View {
  private let logger = getLogger(category: "CompanySearchSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @State private var searchResults = [Company]()
  @State private var status: Status?
  @State private var companyName = ""
  @State private var isLoading = false
  @State private var searchText: String = "" {
    didSet {
      if searchText.isEmpty {
        searchResults = []
      }
    }
  }

  let onSelect: (_ company: Company, _ createdNew: Bool) -> Void

  init(onSelect: @escaping (_ company: Company, _ createdNew: Bool) -> Void) {
    self.onSelect = onSelect
  }

  var showEmptyResults: Bool {
    !isLoading && searchResults.isEmpty && status == .searched && !searchText.isEmpty
  }

  var body: some View {
    List {
      if showEmptyResults {
        Section {
          Text("No companies found with the searched name.")
          if profileManager.hasPermission(.canCreateCompanies) {
            Button("Create new company", action: { createNew() })
          }
        }
      }
      ForEach(searchResults) { company in
        Button(company.name, action: {
          onSelect(company, false)
          dismiss()
        })
      }

      if profileManager.hasPermission(.canCreateCompanies), !showEmptyResults {
        switch status {
        case .searched:
          Section("Didn't find the company you were looking for?") {
            Button("Add", action: { createNew() })
          }.textCase(nil)
        case .add:
          Section("Add new company") {
            TextField("Name", text: $companyName)
            ProgressButton("Create") {
              await createNewCompany(onSuccess: { company in
                onSelect(company, true)
                dismiss()
              })
            }
            .disabled(!companyName.isValidLength(.normal))
          }
        case .none:
          EmptyView()
        }
      }
    }
    .navigationTitle("Search companies")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .onSubmit(of: .search) { Task { await searchCompanies(name: searchText) } }
    .onChange(of: searchText, debounceTime: 0.2, perform: { newValue in
      Task { await searchCompanies(name: newValue) }
    })
  }

  func createNew() {
    companyName = searchText
    status = Status.add
  }

  func searchCompanies(name: String) async {
    guard name.count > 1 else { return }
    switch await repository.company.search(searchTerm: searchText) {
    case let .success(searchResults):
      self.searchResults = searchResults
      status = Status.searched
    case let .failure(error):
      logger.error("failed to search companies: \(error.localizedDescription)")
    }
  }

  func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) async {
    let newCompany = Company.NewRequest(name: companyName)
    switch await repository.company.insert(newCompany: newCompany) {
    case let .success(newCompany):
      onSuccess(newCompany)
    case let .failure(error):
      logger.error("failed to create new company': \(error.localizedDescription)")
    }
  }
}

extension CompanySearchSheet {
  enum Status {
    case add
    case searched
  }
}
