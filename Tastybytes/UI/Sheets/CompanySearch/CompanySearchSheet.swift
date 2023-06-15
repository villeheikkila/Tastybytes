import OSLog
import SwiftUI

struct CompanySearchSheet: View {
    private let logger = Logger(category: "CompanySearchSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
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

    let onSelect: (_ company: Company) -> Void

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
                    onSelect(company)
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
                        ScanTextField(title: "Name", text: $companyName)
                        ProgressButton("Create") {
                            await createNewCompany(onSuccess: { company in
                                onSelect(company)
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
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) { Task { await searchCompanies(name: searchText) } }
        .onChange(of: searchText, debounceTime: 0.5, perform: { newValue in
            Task { await searchCompanies(name: newValue) }
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
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
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to search companies. Error: \(error) (\(#file):\(#line))")
        }
    }

    func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) async {
        let newCompany = Company.NewRequest(name: companyName)
        switch await repository.company.insert(newCompany: newCompany) {
        case let .success(newCompany):
            feedbackManager.toggle(.success("New Company Created!"))
            onSuccess(newCompany)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("Failed to create new company'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension CompanySearchSheet {
    enum Status {
        case add
        case searched
    }
}
