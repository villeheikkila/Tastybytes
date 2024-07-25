import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductMutationView: View {
    typealias ProductCallback = (_ product: Product.Joined) async -> Void

    private let logger = Logger(category: "ProductMutationInnerView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresentedInSheet) private var isPresentedInSheet
    @FocusState private var focusedField: Focusable?
    @State private var primaryActionTask: Task<Void, Never>?
    @State private var state: ScreenState = .loading
    @State private var subcategories = [Subcategory.Saved]()
    @State private var category: Models.Category.JoinedSubcategoriesServingStyles? {
        didSet {
            subcategories = []
        }
    }

    @State private var brandOwner: Company.Saved? {
        didSet {
            brand = nil
            subBrand = nil
            hasSubBrand = false
        }
    }

    @State private var brand: Brand.JoinedSubBrands? {
        didSet {
            hasSubBrand = false
            if let brand {
                subBrand = brand.subBrands.first(where: { $0.name == nil })
            }
        }
    }

    @State private var subBrand: SubBrandProtocol?
    @State private var hasSubBrand = false {
        didSet {
            if oldValue == true {
                subBrand = nil
            }
        }
    }

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isDiscontinued = false
    @State private var barcode: Barcode?

    let mode: Mode

    private var isValid: Bool {
        category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal(allowEmpty: true))
    }

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(isPresentedInSheet ? .hidden : .visible)
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.primary)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .toolbar {
            toolbarContent
        }
        .task {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        categorySection
        brandSection
        productSection
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if isPresentedInSheet {
            ToolbarDismissAction()
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button(mode.doneLabel) {
                primaryActionTask = Task {
                    await primaryAction()
                }
            }
            .foregroundColor(isValid ? .primary : .secondary)
            .fontWeight(.medium)
            .disabled(!isValid || primaryActionTask != nil)
        }
    }

    private var categorySection: some View {
        Section {
            RouterLink(
                category?.name ?? String(localized: "product.mutation.pickCategory.label"),
                open: .sheet(.categoryPicker(category: $category))
            )

            Button(action: {
                if let category {
                    router.open(.sheet(.subcategoryPicker(subcategories: $subcategories, category: category)))
                }
            }, label: {
                HStack {
                    if subcategories.isEmpty {
                        Text("subcategory.title")
                    } else {
                        HStack(spacing: 4) {
                            ForEach(subcategories) { subcategory in
                                SubcategoryLabelView(subcategory: subcategory)
                            }
                        }
                    }
                }
            })
            .disabled(category == nil)
        }
        header: {
            Text("category.title")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
        .customListRowBackground()
    }

    private var brandSection: some View {
        Section {
            PickerLinkRow(
                label: "brand.owner.title",
                selection: brandOwner?.name,
                sheet: .companyPicker(onSelect: { company in
                    brandOwner = company
                })
            )

            if let brandOwner {
                PickerLinkRow(
                    label: "brand.title",
                    selection: brand?.name,
                    sheet: .brandPicker(brandOwner: brandOwner, brand: $brand, mode: .select)
                )
            }

            if brand != nil {
                Toggle("product.mutation.hasSubBrand.label", isOn: .init(get: {
                    hasSubBrand
                }, set: { newValue in
                    hasSubBrand = newValue
                    if newValue == false {
                        subBrand = nil
                    }
                }))
            }

            if hasSubBrand, let brand {
                PickerLinkRow(
                    label: "subBrand.title",
                    selection: subBrand?.name,
                    sheet: .subBrandPicker(brandWithSubBrands: brand, subBrand: $subBrand)
                )
            }

        } header: {
            Text("brand.title")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
        .customListRowBackground()
    }

    private var productSection: some View {
        Section {
            ScanTextFieldView(title: "product.name.placeholder", text: $name)
                .focused($focusedField, equals: .name)
            ScanTextFieldView(title: "product.description.placeholder", text: $description)
                .focused($focusedField, equals: .description)

            if mode.showBarcodeSection {
                RouterLink(
                    barcode == nil ? "product.barcode.add.label" : "product.barcode.added.label",
                    open: .sheet(.barcodeScanner(onComplete: { barcode in
                        self.barcode = barcode
                    }))
                )
            }
            Toggle("product.isDiscontinued.label", isOn: $isDiscontinued)
        } header: {
            Text("product.title")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
        .customListRowBackground()
    }

    private func primaryAction() async {
        guard primaryActionTask != nil else { return }
        defer { primaryActionTask = nil }
        switch mode {
        case let .editSuggestion(product):
            guard let subBrand, let category else { return }
            let diffFromCurrent = Product.EditSuggestionRequest(
                id: product.id,
                name: name,
                description: description,
                subBrand: subBrand,
                category: category,
                isDiscontinued: isDiscontinued
            ).diff(from: product)
            guard let diffFromCurrent else {
                router.open(.toast(.error("product.editSuggestion.nothingToEdit.toast")))
                return
            }
            do {
                try await repository.product.createUpdateSuggestion(productEditSuggestionParams: diffFromCurrent)
                dismiss()
                router.open(.toast(.success("product.editSuggestion.success.toast")))
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init(title: "product.error.failedToCreateEditSuggestion.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                })))
                logger.error("Failed to create product edit suggestion for '\(product.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .edit(product, onEdit):
            guard let category, let brand else { return }
            let subBrandWithNil = subBrand == nil ? brand.subBrands.first(where: { $0.name == nil }) : subBrand
            guard let subBrandWithNil else { return }
            do {
                let updatedProduct = try await repository.product.editProduct(productEditParams: .init(
                    productId: product.id,
                    name: name,
                    description: description,
                    categoryId: category.id,
                    subBrandId: subBrandWithNil.id,
                    subcategories: Array(subcategories),
                    isDiscontinued: isDiscontinued
                ))
                if let onEdit {
                    await onEdit(updatedProduct)
                }
                dismiss()
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init(title: "product.error.failedToUpdate.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                })))
                logger.error("Failed to edit product '\(product.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .new(_, onCreate), let .addToBrand(_, onCreate), let .addToSubBrand(_, _, onCreate):
            guard let category, let brandId = brand?.id else { return }
            do {
                let newProduct = try await repository.product.create(newProductParams: .init(
                    name: name,
                    description: description,
                    categoryId: category.id,
                    brandId: brandId,
                    subBrandId: subBrand?.id,
                    subcategories: Array(subcategories),
                    isDiscontinued: isDiscontinued,
                    barcode: barcode
                ))
                if isPresentedInSheet {
                    dismiss()
                }
                if let onCreate {
                    await onCreate(newProduct)
                }
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init(title: "product.error.failedToCreate.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                })))
                logger.error("Failed to create new product. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    private func initialize() async {
        switch mode {
        case let .edit(initialProduct, _), let .editSuggestion(initialProduct):
            do {
                let brandsWithSubBrands = try await repository.brand.getByBrandOwnerId(id: initialProduct.subBrand.brand.brandOwner.id)
                category = appEnvironmentModel.categories.first(where: { category in
                    category.id == initialProduct.category.id
                })
                subcategories = initialProduct.subcategories.map { .init(subcategory: $0) }
                brandOwner = initialProduct.subBrand.brand.brandOwner
                brand = brandsWithSubBrands.first(where: { $0.id == initialProduct.subBrand.brand.id })
                if initialProduct.subBrand.name != nil {
                    hasSubBrand = true
                }
                subBrand = initialProduct.subBrand
                name = initialProduct.name ?? ""
                description = initialProduct.description.orEmpty
                isDiscontinued = initialProduct.isDiscontinued
                state = .populated
            } catch {
                guard !error.isCancelled else { return }
                state = .error([error])
                logger.error("Failed to load brand owner for product '\(initialProduct.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .addToBrand(brand, _):
            brandOwner = brand.brandOwner
            self.brand = .init(brand: brand)
            state = .populated
        case let .addToSubBrand(brand, subBrand, _):
            brandOwner = brand.brandOwner
            self.brand = .init(brand: brand)
            if subBrand.name != nil {
                hasSubBrand = true
            }
            self.subBrand = brand.subBrands.map(\.subBrand).first(where: { $0.id == subBrand.id })
            state = .populated
        case let .new(barcode, _):
            self.barcode = barcode
            state = .populated
        }
    }
}

extension ProductMutationView {
    enum Mode: Equatable {
        case new(barcode: Barcode?, onCreate: ProductCallback? = nil), edit(Product.Joined, onEdit: ProductCallback?), editSuggestion(Product.Joined),
             addToBrand(Brand.JoinedSubBrandsProductsCompany, onCreate: ProductCallback?),
             addToSubBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct, onCreate: ProductCallback?)

        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case let (.new(lhsBarcode, _), .new(rhsBarcode, _)):
                lhsBarcode == rhsBarcode
            case let (.edit(lhsProduct, _), .edit(rhsProduct, _)):
                lhsProduct == rhsProduct
            case let (.editSuggestion(lhsProduct), .editSuggestion(rhsProduct)):
                lhsProduct == rhsProduct
            case let (.addToBrand(lhsBrand, _), .addToBrand(rhsBrand, _)):
                lhsBrand == rhsBrand
            case let (.addToSubBrand(lhsBrand, lhsSubBrand, _), .addToSubBrand(rhsBrand, rhsSubBrand, _)):
                lhsBrand == rhsBrand && lhsSubBrand == rhsSubBrand
            default:
                false
            }
        }

        var doneLabel: LocalizedStringKey {
            switch self {
            case .edit:
                "labels.edit"
            case .editSuggestion:
                "labels.submit"
            case .new, .addToBrand, .addToSubBrand:
                "labels.create"
            }
        }

        var showBarcodeSection: Bool {
            switch self {
            case .addToBrand, .addToSubBrand, .new:
                true
            case .edit, .editSuggestion:
                false
            }
        }

        var navigationTitle: LocalizedStringKey {
            switch self {
            case .addToBrand, .addToSubBrand, .new:
                "product.mutation.create.title"
            case .edit:
                "product.mutation.edit.title"
            case .editSuggestion:
                "product.mutation.editSuggestion.title"
            }
        }
    }

    enum Focusable {
        case name, description
    }
}
