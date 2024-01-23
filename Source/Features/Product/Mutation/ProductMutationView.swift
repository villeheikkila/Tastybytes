import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProductMutationView: View {
    private let logger = Logger(category: "ProductMutationInnerView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Focusable?
    // Sheet status
    @State private var isSuccess = false
    @State private var sheet: Sheet?
    @State private var status: Status = .initial
    @State private var alertError: AlertError?
    // Product details
    @State private var subcategories: Set<Int> = Set()
    @State private var category: Int? {
        didSet {
            subcategories = []
        }
    }

    @State private var brandOwner: Company? {
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
    let isSheet: Bool
    let onEdit: (() async -> Void)?
    let onCreate: ((_ product: Product.Joined) async -> Void)?

    init(
        mode: Mode,
        isSheet: Bool = true,
        initialBarcode: Barcode? = nil,
        onEdit: (() async -> Void)? = nil,
        onCreate: ((_ product: Product.Joined) -> Void)? = nil
    ) {
        self.mode = mode
        self.isSheet = isSheet
        _barcode = State(initialValue: initialBarcode)
        self.onEdit = onEdit
        self.onCreate = onCreate
    }

    private var selectedCategory: Models.Category.JoinedSubcategoriesServingStyles? {
        appEnvironmentModel.categories.first(where: { $0.id == category })
    }

    private var selectedSubcategories: [Subcategory] {
        selectedCategory?.subcategories.filter { subcategories.contains($0.id) } ?? []
    }

    private var isValid: Bool {
        category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal)
    }

    var body: some View {
        Form {
            categorySection
            brandSection
            productSection
        }
        .navigationTitle(mode.navigationTitle)
        .foregroundColor(.primary)
        .alertError($alertError)
        .toolbar {
            toolbarContent
        }
        .task {
            await initialize()
        }
        .sheets(item: $sheet)
        .sensoryFeedback(.success, trigger: isSuccess)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if isSheet {
            ToolbarDismissAction()
        }
        ToolbarItemGroup(placement: .primaryAction) {
            ProgressButton(mode.doneLabel, action: {
                await primaryAction()
            })
            .foregroundColor(isValid ? .primary : .secondary)
            .fontWeight(.medium)
            .disabled(!isValid)
        }
    }

    private var categorySection: some View {
        Section {
            Button(
                selectedCategory?.name ?? "Pick a category",
                action: {
                    sheet = .categoryPickerSheet(category: $category)
                }
            )

            Button(action: {
                if let selectedCategory {
                    sheet = .subcategory(
                        subcategories: $subcategories,
                        category: selectedCategory
                    )
                }
            }, label: {
                HStack {
                    if subcategories.isEmpty {
                        Text("Subcategories")
                    } else {
                        HStack(spacing: 4) {
                            ForEach(selectedSubcategories) { subcategory in
                                SubcategoryLabelView(subcategory: subcategory)
                            }
                        }
                    }
                }
            })
            .disabled(category == nil)
        }
        header: {
            Text("Category")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
    }

    private var brandSection: some View {
        Section {
            PickerLinkRow(
                shownSheet: $sheet,
                label: "Brand Owner",
                selection: brandOwner?.name,
                sheet: .companySearch(onSelect: { company in
                    brandOwner = company
                })
            )

            if let brandOwner {
                PickerLinkRow(
                    shownSheet: $sheet,
                    label: "Brand",
                    selection: brand?.name,
                    sheet: .brand(brandOwner: brandOwner, brand: $brand, mode: .select)
                )
            }

            if brand != nil {
                Toggle("Has a sub-brand?", isOn: .init(get: {
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
                    shownSheet: $sheet,
                    label: "Sub-brand",
                    selection: subBrand?.name,
                    sheet: .subBrand(brandWithSubBrands: brand, subBrand: $subBrand)
                )
            }

        } header: {
            Text("Brand")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
    }

    private var productSection: some View {
        Section {
            ScanTextField(title: "Name", text: $name)
                .focused($focusedField, equals: .name)
            ScanTextField(title: "Description (optional)", text: $description)
                .focused($focusedField, equals: .description)

            if mode.showBarcodeSection {
                Button(
                    barcode == nil ? "Add Barcode" : "Barcode Added!",
                    action: { sheet = .barcodeScanner(onComplete: { barcode in
                        self.barcode = barcode
                    }) }
                )
            }
            Toggle("No longer in production", isOn: $isDiscontinued)
        } header: {
            Text("Product")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }
        }
        .headerProminence(.increased)
    }

    func primaryAction() async {
        switch mode {
        case let .editSuggestion(product):
            await createProductEditSuggestion(product: product)
        case let .edit(product):
            await editProduct(product: product)
            if let onEdit {
                await onEdit()
            }
        case .new, .addToBrand, .addToSubBrand:
            await createProduct(onSuccess: { product in
                if let onCreate {
                    await onCreate(product)
                }
            })
        }
    }

    func initialize() async {
        switch mode {
        case let .edit(initialProduct), let .editSuggestion(initialProduct):
            switch await repository.brand
                .getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id)
            {
            case let .success(brandsWithSubBrands):
                category = initialProduct.category.id
                subcategories = Set(initialProduct.subcategories.map(\.id))
                brandOwner = initialProduct.subBrand.brand.brandOwner
                brand = Brand.JoinedSubBrands(
                    id: initialProduct.subBrand.brand.id,
                    name: initialProduct.subBrand.brand.name,
                    logoFile: initialProduct.subBrand.brand.logoFile,
                    isVerified: initialProduct.subBrand.brand.isVerified,
                    subBrands: brandsWithSubBrands
                        .first(where: { $0.id == initialProduct.subBrand.brand.id })?.subBrands ?? []
                )
                if initialProduct.subBrand.name != nil {
                    hasSubBrand = true
                }
                subBrand = initialProduct.subBrand
                name = initialProduct.name
                description = initialProduct.description.orEmpty
                isDiscontinued = initialProduct.isDiscontinued
                status = .initialized
            case let .failure(error):
                guard !error.isCancelled else { return }
                status = .error(error)
                logger.error("Failed to load brand owner for product '\(initialProduct.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .addToBrand(brand):
            brandOwner = brand.brandOwner
            self.brand = Brand.JoinedSubBrands(
                id: brand.id,
                name: brand.name,
                logoFile: brand.logoFile,
                isVerified: brand.isVerified,
                subBrands: brand.subBrands
                    .map { subBrand in
                        SubBrand(id: subBrand.id, name: subBrand.name,
                                 isVerified: subBrand.isVerified)
                    }
            )
            status = .initialized
        case let .addToSubBrand(brand, subBrand):
            let subBrandsFromBrand = brand.subBrands
                .map { subBrand in SubBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified) }

            brandOwner = brand.brandOwner
            self.brand = Brand.JoinedSubBrands(
                id: brand.id,
                name: brand.name,
                logoFile: brand.logoFile,
                isVerified: brand.isVerified,
                subBrands: subBrandsFromBrand
            )
            self.subBrand = subBrandsFromBrand.first(where: { $0.id == subBrand.id })
            status = .initialized
        case .new:
            category = appEnvironmentModel.categories.first?.id
            status = .initialized
        }
    }

    func createProduct(onSuccess: @escaping (_ product: Product.Joined) async -> Void) async {
        guard let category, let brandId = brand?.id else { return }
        let newProductParams = Product.NewRequest(
            name: name,
            description: description,
            categoryId: category,
            brandId: brandId,
            subBrandId: subBrand?.id,
            subCategoryIds: Array(subcategories),
            isDiscontinued: isDiscontinued,
            barcode: barcode
        )
        switch await repository.product.create(newProductParams: newProductParams) {
        case let .success(newProduct):
            isSuccess = true
            if isSheet {
                dismiss()
            }
            router.navigate(screen: .product(newProduct), removeLast: true)
            await onSuccess(newProduct)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create new product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func createProductEditSuggestion(product: Product.Joined) async {
        guard let subBrand, let selectedCategory else { return }
        let editSuggestion = Product.EditSuggestionRequest(
            id: product.id,
            name: name,
            description: description,
            subBrand: subBrand,
            category: selectedCategory,
            isDiscontinued: isDiscontinued
        )

        let diffFromCurrent = editSuggestion.diff(from: product)
        guard let diffFromCurrent else {
            feedbackEnvironmentModel.toggle(.warning("There is nothing to edit"))
            return
        }

        switch await repository.product
            .createUpdateSuggestion(productEditSuggestionParams: diffFromCurrent)
        {
        case .success:
            dismiss()
            feedbackEnvironmentModel.toggle(.success("Edit suggestion sent!"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Failed to create product edit suggestion for '\(product.id)'. Error: \(error) (\(#file):\(#line))"
                )
        }
    }

    func editProduct(product: Product.Joined) async {
        guard let category, let brand else { return }
        let subBrandWithNil = subBrand == nil ? brand.subBrands.first(where: { $0.name == nil }) : subBrand
        guard let subBrandWithNil else { return }
        let productEditParams = Product.EditRequest(
            productId: product.id,
            name: name,
            description: description,
            categoryId: category,
            subBrandId: subBrandWithNil.id,
            subcategories: selectedSubcategories,
            isDiscontinued: isDiscontinued
        )

        switch await repository.product.editProduct(productEditParams: productEditParams) {
        case .success:
            isSuccess = true
            dismiss()
            if let onEdit {
                await onEdit()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to edit product '\(product.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension ProductMutationView {
    enum Status: Sendable, Equatable {
        case initial
        case initialized
        case error(Error)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial),
                 (.initialized, .initialized):
                true
            default:
                false
            }
        }
    }

    enum Mode: Equatable {
        case new, edit(Product.Joined), editSuggestion(Product.Joined),
             addToBrand(Brand.JoinedSubBrandsProductsCompany),
             addToSubBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct)

        var doneLabel: String {
            switch self {
            case .edit:
                "Edit"
            case .editSuggestion:
                "Submit"
            case .new, .addToBrand, .addToSubBrand:
                "Create"
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

        var navigationTitle: String {
            switch self {
            case .addToBrand, .addToSubBrand, .new:
                "Add Product"
            case .edit:
                "Edit Product"
            case .editSuggestion:
                "Edit Suggestion"
            }
        }
    }

    enum Focusable {
        case name, description
    }
}
