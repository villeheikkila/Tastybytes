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
    @State private var showCreateModal = false
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
        .sheet(isPresented: $showCreateModal) {
            CompanyCreateView { company in
                onSelect(company)
                dismiss()
            }
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.height(200)])
            .presentationCornerRadius(24)
            .presentationSizing(.form)
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if searchResults.isEmpty {
                if !searchTerm.isEmpty {
                    if showEmptyResults {
                        ContentUnavailableView {
                            Label("company.search.noResults.title", systemImage: "magnifyingglass")
                        } actions: {
                            Button("company.search.noResults.create.label", action: { showCreateModal = true })
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
}

extension CompanyPickerSheet {
    enum Status {
        case add
        case searched
    }
}

struct CompanyCreateView: View {
    private let logger = Logger(label: "CompanyCreateView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var companyName: String
    let onSuccess: (Company.Saved) -> Void

    init(initialName: String = "", onSuccess: @escaping (Company.Saved) -> Void) {
        _companyName = State(initialValue: initialName)
        self.onSuccess = onSuccess
    }

    var body: some View {
        Form {
            CRCompanyView(label: "Name of the company", name: $companyName) {}
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            AsyncButton("company.create.label") {
                await createNewCompany()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!companyName.isValidLength(.normal(allowEmpty: false)))
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    private func createNewCompany() async {
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

struct CRCompanyView: View {
    @State private var isFocused = false
    @FocusState private var textFieldFocus: Bool

    let label: LocalizedStringKey
    @Binding var name: String
    let onAddLogo: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            AddLogoView(action: onAddLogo)
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary.opacity(0.8))
                TextField("", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.primary.opacity(0.8))
                    .tint(.primary.opacity(0.8))
                    .focused($textFieldFocus)
                    .onChange(of: textFieldFocus) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isFocused = newValue
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                .linearGradient(
                                    colors: textFieldFocus ? [.blue.opacity(0.5), .purple.opacity(0.5), .blue.opacity(0.5)] : [.primary.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                            .animation(
                                .linear(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: isFocused
                            )
                    }
            }
        }
    }
}
