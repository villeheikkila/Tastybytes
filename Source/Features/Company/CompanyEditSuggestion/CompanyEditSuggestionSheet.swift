import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct CompanyEditSuggestionSheet: View {
    private let logger = Logger(category: "CompanyEditSuggestionSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var company: Company
    @State private var newCompanyName = ""

    let onSuccess: () async -> Void

    init(company: Company, onSuccess: @escaping () async -> Void) {
        _company = State(initialValue: company)
        _newCompanyName = State(initialValue: company.name)
        self.onSuccess = onSuccess
    }

    var body: some View {
        Form {
            Section("company.editSuggestion.section.name.title") {
                TextField("company.edit.name.placeholder", text: $newCompanyName)
                ProgressButton("labels.send", action: {
                    await sendCompanyEditSuggestion()
                })
                .disabled(!newCompanyName.isValidLength(.normal(allowEmpty: true)))
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
    }

    func sendCompanyEditSuggestion() async {
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
