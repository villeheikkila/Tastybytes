import SwiftUI

struct CompanyEditSuggestionSheet: View {
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss

  let onSubmit: () -> Void

  init(_ client: Client, company: Company, onSubmit: @escaping () -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, company: company))
    self.onSubmit = onSubmit
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newCompanyNameSuggestion)
        Button("Send") {
          onSubmit()
          dismiss()
        }
        .disabled(!viewModel.newCompanyNameSuggestion.isValidLength(.normal) || viewModel.company.name == viewModel
          .newCompanyNameSuggestion)
      } header: {
        Text("What should the company be called?")
      }
    }
    .navigationTitle("Edit suggestion")
  }
}

extension CompanyEditSuggestionSheet {
  @MainActor
  class ViewModel: ObservableObject {
    let client: Client
    let company: Company
    @Published var newCompanyNameSuggestion = ""

    init(_ client: Client, company: Company) {
      self.client = client
      self.company = company
      newCompanyNameSuggestion = company.name
    }

    func sendCompanyEditSuggestion() {}
  }
}
