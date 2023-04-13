import SwiftUI

struct CompanySearchSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let onSelect: (_ company: Company, _ createdNew: Bool) -> Void

  init(_ client: Client, onSelect: @escaping (_ company: Company, _ createdNew: Bool) -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      if viewModel.showEmptyResults {
        Section {
          Text("No companies found with the searched name.")
          if profileManager.hasPermission(.canCreateCompanies) {
            Button("Create new company", action: { viewModel.createNew() })
          }
        }
      }
      ForEach(viewModel.searchResults) { company in
        Button(company.name, action: {
          onSelect(company, false)
          dismiss()
        })
      }

      if profileManager.hasPermission(.canCreateCompanies), !viewModel.showEmptyResults {
        switch viewModel.status {
        case .searched:
          Section {
            Button("Add", action: { viewModel.createNew() })
          } header: {
            Text("Didn't find the company you were looking for?")
          }.textCase(nil)
        case .add:
          Section {
            TextField("Name", text: $viewModel.companyName)
            ProgressButton("Create") {
              await viewModel.createNewCompany(onSuccess: { company in
                onSelect(company, true)
                dismiss()
              })
            }
            .disabled(!viewModel.companyName.isValidLength(.normal))
          } header: {
            Text("Add new company")
          }
        case .none:
          EmptyView()
        }
      }
    }
    .navigationTitle("Search companies")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
    .onSubmit(of: .search) { Task { await viewModel.searchCompanies() } }
    .onReceive(
      viewModel.$searchText.debounce(for: 0.2, scheduler: RunLoop.main)
    ) { _ in
      if viewModel.searchText.count > 1 {
        Task { await viewModel.searchCompanies() }
      }
    }
  }
}
