import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct SubBrandEditSuggestionSheet: View {
    private let logger = Logger(category: "SubBrandEditSuggestionSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    let subBrand: SubBrand.JoinedBrand
    @State private var name: String
    @State private var brand: Brand.JoinedSubBrands?
    @State private var includesBrandName: Bool

    let onSuccess: () async -> Void

    init(brand: Brand.JoinedSubBrands, subBrand: SubBrand.JoinedBrand, onSuccess: @escaping () async -> Void) {
        self.subBrand = subBrand
        _name = State(initialValue: subBrand.name ?? "")
        _brand = State(initialValue: brand)
        _includesBrandName = State(initialValue: subBrand.includesBrandName)
        self.onSuccess = onSuccess
    }

    private var isValidNameUpdate: Bool {
        name.isValidLength(.normal(allowEmpty: true)) && subBrand.name != name
    }

    private var isBrandUpdate: Bool {
        brand?.id != subBrand.brand.id
    }
    
    private var isIncludesBrandNameUpdate: Bool {
        includesBrandName != subBrand.includesBrandName
    }
    
    private var isUpdate: Bool {
        isValidNameUpdate || isBrandUpdate || isIncludesBrandNameUpdate
    }

    var body: some View {
        Form {
            Section("subBrand.editSuggestion.section.name.title") {
                TextField("subBrand.edit.name.placeholder", text: $name)
                Toggle("brand.includesBrandName.toggle.label", isOn: $includesBrandName)
            }
            .customListRowBackground()
            Section("subBrand.editSuggestion.section.brand.title") {
                LabeledContent("subBrand.editSuggestion.brand.label") {
                    RouterLink(
                        subBrand.brand.name,
                        open: .sheet(
                            .brandPicker(
                                brandOwner: subBrand.brand.brandOwner,
                                brand: $brand,
                                mode: .select
                            )))
                }
            }
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: name)
        .navigationTitle("subBrand.editSuggestion.navigationTitle")
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
            .disabled(!isUpdate)
        }
    }

    private func submitEditSuggestion() async {
        do {
            try await repository.subBrand
                .createEditSuggestion(
                    subBrand: subBrand,
                    brand: isBrandUpdate ?  brand : nil,
                    name: isValidNameUpdate ? name : nil,
                    includesBrandName: isIncludesBrandNameUpdate ? includesBrandName : nil
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
