import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct CompanyPickerSheet: View {
    private let logger = Logger(label: "CompanyPickerSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults = [Company.Saved]()
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

    let filterCompanies: [Company.Saved]
    let onSelect: (_ company: Company.Saved) -> Void

    init(
        filterCompanies: [Company.Saved] = [],
        onSelect: @escaping (_: Company.Saved) -> Void
    ) {
        self.filterCompanies = filterCompanies
        self.onSelect = onSelect
    }

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
            if status != nil, profileModel.hasPermission(.canCreateCompanies), !showEmptyResults {
                Form {
                    if status == .searched {
                        Section("company.create.notFound.section.title") {
                            Button("company.create.label", action: { createNew() })
                        }
                        .customListRowBackground()
                    }
                    if status == .add {
                        Section("company.create.section.title") {
                            ScanTextFieldView(title: "company.name.placeholder", text: $companyName)
                            AsyncButton("company.create.label") {
                                await createNewCompany(onSuccess: { company in
                                    onSelect(company)
                                    dismiss()
                                })
                            }
                            .disabled(!companyName.isValidLength(.normal(allowEmpty: false)))
                        }
                        .customListRowBackground()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
                .animation(.default, value: status)
                .frame(height: status == .add ? 150 : 100)
                .clipShape(.rect(cornerRadius: 8))
                .padding()
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
        .navigationBarTitleDisplayMode(.inline)
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
            let searchResults = try await repository.company.search(filterCompanies: filterCompanies, searchTerm: searchTerm)
            self.searchResults = searchResults
            status = .searched
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to search companies. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func createNewCompany(onSuccess: @escaping (_ company: Company.Saved) -> Void) async {
        do {
            let newCompany = try await repository.company.insert(newCompany: .init(name: companyName))
            router.open(.toast(.success("company.create.success.toast")))
            onSuccess(newCompany)
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isDuplicate else {
                router.open(.toast(.warning("labels.duplicate.toast")))
                return
            }
            router.open(.alert(.init()))
            logger.error("Failed to create new company'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension CompanyPickerSheet {
    enum Status {
        case add
        case searched
    }
}
