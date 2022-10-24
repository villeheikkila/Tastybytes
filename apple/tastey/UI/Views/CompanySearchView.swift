import SwiftUI
import AlertToast

struct CompanySearchView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

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
                            viewModel.onAdd()
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

extension CompanySearchView {
    enum Status {
        case add
        case searched
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchResults = [Company]()
        @Published var status: Status? = nil
        @Published var companyName = ""
        
        func onAdd() {
            self.companyName = searchText
            self.status = Status.add
        }
        
        func searchCompanies() {
            Task {
                do {
                    let searchResults = try await repository.company.search(searchTerm: searchText)
                    DispatchQueue.main.async {
                        self.searchResults = searchResults
                        self.status = Status.searched
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }

        func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) {
            let newCompany = NewCompany(name: companyName)
            Task {
                do {
                    let newCompany = try await repository.company.insert(newCompany: newCompany)
                    onSuccess(newCompany)
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
