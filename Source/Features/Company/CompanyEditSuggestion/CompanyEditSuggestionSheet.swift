import Components
import Models
import Logging
import Repositories
import SwiftUI

struct CompanyEditSuggestionSheet: View {
    private let logger = Logger(label: "CompanyEditSuggestionSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var company: any CompanyProtocol
    @State private var newCompanyName = ""

    let onSuccess: () async -> Void

    init(company: any CompanyProtocol, onSuccess: @escaping () async -> Void) {
        _company = State(initialValue: company)
        _newCompanyName = State(initialValue: company.name)
        self.onSuccess = onSuccess
    }

    private var canUpdate: Bool {
        newCompanyName.isValidLength(.normal(allowEmpty: true)) && company.name != newCompanyName
    }

    var body: some View {
        Form {
            Section("company.editSuggestion.section.name.title") {
                TextField("company.edit.name.placeholder", text: $newCompanyName)
            }
            .headerProminence(.increased)
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("company.editSuggestion.label")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.send", action: {
                await sendCompanyEditSuggestion()
            })
            .bold()
            .disabled(!canUpdate)
        }
    }

    private func sendCompanyEditSuggestion() async {
        do {
            try await repository.company.editSuggestion(updateRequest: Company.EditSuggestionRequest(id: company.id, name: newCompanyName))
            dismiss()
            await onSuccess()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to send company edit suggestion. Error: \(error) (\(#file):\(#line))")
        }
    }
}
