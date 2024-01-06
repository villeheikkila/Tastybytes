import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CompanySearchSheet: View {
    private let logger = Logger(category: "CompanySearchSheet")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults = [Company]()
    @State private var status: Status?
    @State private var companyName = ""
    @State private var isLoading = false
    @State private var alertError: AlertError?
    @State private var searchTerm: String = "" {
        didSet {
            if searchTerm.isEmpty {
                searchResults = []
            }
        }
    }

    let onSelect: (_ company: Company) -> Void

    var showEmptyResults: Bool {
        !isLoading && searchResults.isEmpty && status == .searched && !searchTerm.isEmpty
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && searchResults.isEmpty
    }

    var body: some View {
        List {
            if showEmptyResults {
                Section {
                    Text("No companies found with the searched name.")
                    if profileEnvironmentModel.hasPermission(.canCreateCompanies) {
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

            if profileEnvironmentModel.hasPermission(.canCreateCompanies), !showEmptyResults {
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
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("Search companies")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) { Task { await searchCompanies(name: searchTerm) } }
        .onChange(of: searchTerm, debounceTime: 0.5, perform: { newValue in
            Task { await searchCompanies(name: newValue) }
        })
        .alertError($alertError)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            Button("actions.cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func createNew() {
        companyName = searchTerm
        status = Status.add
    }

    func searchCompanies(name: String) async {
        guard name.count > 1 else { return }
        switch await repository.company.search(searchTerm: searchTerm) {
        case let .success(searchResults):
            self.searchResults = searchResults
            status = Status.searched
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to search companies. Error: \(error) (\(#file):\(#line))")
        }
    }

    func createNewCompany(onSuccess: @MainActor @escaping (_ company: Company) -> Void) async {
        let newCompany = Company.NewRequest(name: companyName)
        switch await repository.company.insert(newCompany: newCompany) {
        case let .success(newCompany):
            feedbackEnvironmentModel.toggle(.success("New Company Created!"))
            onSuccess(newCompany)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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
