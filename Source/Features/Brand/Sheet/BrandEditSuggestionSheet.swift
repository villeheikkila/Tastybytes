import Components
import Logging
import Models
import Repositories
import SwiftUI

struct BrandEditSuggestionSheet: View {
    private let logger = Logger(label: "BrandEditSuggestionSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var brand: Brand.JoinedSubBrandsCompany
    @State private var newBrandName: String
    @State private var brandOwner: Company.Saved

    let onSuccess: () async -> Void

    init(brand: Brand.JoinedSubBrandsCompany, onSuccess: @escaping () async -> Void) {
        _brand = State(initialValue: brand)
        _newBrandName = State(initialValue: brand.name)
        _brandOwner = State(initialValue: brand.brandOwner)
        self.onSuccess = onSuccess
    }

    private var isValidNameUpdateRequst: Bool {
        newBrandName.isValidLength(.normal(allowEmpty: true)) && brand.name != newBrandName
    }

    private var canUpdate: Bool {
        isValidNameUpdateRequst || brandOwner != brand.brandOwner
    }

    var body: some View {
        Form {
            Section("brand.editSuggestion.section.name.title") {
                TextField("brand.edit.name.placeholder", text: $newBrandName)
            }
            .customListRowBackground()
            Section("brand.editSuggestion.section.brandOwner.title") {
                LabeledContent("brand.admin.changeBrandOwner.label") {
                    RouterLink(brandOwner.name, open: .sheet(.companyPicker(onSelect: { company in
                        brandOwner = company
                    })))
                }
            }
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: brandOwner)
        .navigationTitle("brand.editSuggestion.label")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.send", action: {
                await submitEditSuggestion()
            })
            .bold()
            .disabled(!canUpdate)
        }
    }

    private func submitEditSuggestion() async {
        do {
            try await repository.brand
                .editSuggestion(
                    .init(
                        brand: brand,
                        name: (newBrandName == brand.name || isValidNameUpdateRequst) ? nil : newBrandName,
                        brandOwner: brandOwner != brand.brandOwner ? brandOwner : nil
                    )
                )
            dismiss()
            await onSuccess()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to send company edit suggestion. Error: \(error) (\(#file):\(#line))")
        }
    }
}
