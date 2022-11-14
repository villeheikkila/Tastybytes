import AlertToast
import SwiftUI

struct CompanySheetView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @State var companyName = ""
    let onSelect: (_ company: Company, _ createdNew: Bool) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults, id: \.id) { company in
                    Button(action: {
                        self.onSelect(company, false)
                        dismiss()
                    }) {
                        Text(company.name)
                    }
                }

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
            .navigationTitle("Search companies")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Cancel").bold()
            })
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search, { viewModel.searchCompanies() })
        }
    }
}

extension CompanySheetView {
    enum Status {
        case add
        case searched
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchResults = [Company]()
        @Published var status: Status? = nil
        @Published var companyName = ""

        func createNew() {
            DispatchQueue.main.async {
                self.companyName = self.searchText
                self.status = Status.add
            }
        }

        func searchCompanies() {
            Task {
                switch await repository.company.search(searchTerm: searchText) {
                case let .success(searchResults):
                    await MainActor.run {
                        self.searchResults = searchResults
                        self.status = Status.searched
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) {
            let newCompany = NewCompany(name: companyName)
            Task {
                switch await repository.company.insert(newCompany: newCompany) {
                case let .success(newCompany):
                    onSuccess(newCompany)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
