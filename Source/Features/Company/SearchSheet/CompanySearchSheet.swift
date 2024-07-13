import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CompanySearchSheet: View {
    private let logger = Logger(category: "CompanySearchSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults = [Company]()
    @State private var status: Status?
    @State private var companyName = ""
    @State private var isLoading = false
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

    var body: some View {
        List(searchResults) { company in
            CompanyResultRow(company: company) {
                onSelect(company)
                dismiss()
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            if profileEnvironmentModel.hasPermission(.canCreateCompanies), !showEmptyResults {
                if status == .searched {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("company.create.notFound.section.title")
                        Button("company.create.label", action: { createNew() })
                    }
                    .padding()
                    .frame(width: .infinity)
                    .background(.ultraThinMaterial)
                }
                if status == .add {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("company.create.section.title")
                        ScanTextFieldView(title: "company.name.placeholder", text: $companyName)
                        AsyncButton("company.create.label") {
                            await createNewCompany(onSuccess: { company in
                                onSelect(company)
                                dismiss()
                            })
                        }
                        .disabled(!companyName.isValidLength(.normal(allowEmpty: false)))
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.black)
                        .controlSize(.large)
                    }
                    .padding()
                    .frame(width: .infinity)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .overlay {
            if searchResults.isEmpty {
                if !searchTerm.isEmpty {
                    if showEmptyResults {
                        ContentUnavailableView {
                            Label("company.search.noResults.title", systemImage: "magnifyingglass")
                        } actions: {
                            Button("company.search.noResults.create.label", action: { createNew() })
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                        }
                    } else {
                        ContentUnavailableView.search(text: searchTerm)
                    }
                } else {
                    ContentUnavailableView("company.search.empty.title", systemImage: "magnifyingglass")
                }
            }
        }
        .navigationTitle("company.search.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) { Task { await search(searchTerm: searchTerm) } }
        .onChange(of: searchTerm, debounceTime: 0.5, perform: { newValue in
            Task { await search(searchTerm: newValue) }
        })
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func createNew() {
        companyName = searchTerm
        status = .add
    }

    private func search(searchTerm: String) async {
        guard searchTerm.count > 1 else { return }
        do {
            let searchResults = try await repository.company.search(searchTerm: searchTerm)
            self.searchResults = searchResults
            status = .searched
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to search companies. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func createNewCompany(onSuccess: @escaping (_ company: Company) -> Void) async {
        do {
            let newCompany = try await repository.company.insert(newCompany: .init(name: companyName))
            router.open(.toast(.success("company.create.success.toast")))
            onSuccess(newCompany)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
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
