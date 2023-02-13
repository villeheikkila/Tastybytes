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
      ForEach(viewModel.searchResults, id: \.id) { company in
        Button(action: {
          self.onSelect(company, false)
          dismiss()
        }) {
          Text(company.name)
        }
      }

      if profileManager.hasPermission(.canCreateCompanies) {
        switch viewModel.status {
        case .searched:
          Section {
            Button(action: {
              viewModel.createNew()
            }) {
              Text("Add")
            }
          } header: {
            Text("Didn't find the company you were looking for?")
          }.textCase(nil)
        case .add:
          Section {
            TextField("Name", text: $viewModel.companyName)
            Button("Create") {
              viewModel.createNewCompany(onSuccess: {
                company in self.onSelect(company, true)
                dismiss()
              })
            }
            .disabled(!validateStringLength(str: viewModel.companyName, type: .normal))
          } header: {
            Text("Add new company")
          }
        case .none:
          EmptyView()
        }
      }
    }
    .navigationTitle("Search companies")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) { viewModel.searchCompanies() }
  }
}
