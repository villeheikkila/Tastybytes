import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductMutationView: View {
    private let logger = Logger(category: "ProductMutationView")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var initialValues: ProductMutationInitialValues?
    @State private var alertError: AlertError?

    let mode: ProductMutationInnerView.Mode
    let onEdit: (() async -> Void)?
    let onCreate: ((_ product: Product.Joined) -> Void)?
    let initialBarcode: Barcode?
    let isSheet: Bool

    init(
        mode: ProductMutationInnerView.Mode,
        isSheet: Bool = true,
        initialBarcode: Barcode? = nil,
        onEdit: (() async -> Void)? = nil,
        onCreate: ((_ product: Product.Joined) -> Void)? = nil
    ) {
        self.mode = mode
        self.isSheet = isSheet
        self.initialBarcode = initialBarcode
        self.onEdit = onEdit
        self.onCreate = onCreate
    }

    var navigationTitle: String {
        switch mode {
        case .addToBrand, .addToSubBrand, .new:
            "Add Product"
        case .edit:
            "Edit Product"
        case .editSuggestion:
            "Edit Suggestion"
        }
    }

    var body: some View {
        VStack {
            if let initialValues {
                ProductMutationInnerView(mode: mode, isSheet: isSheet, initialValues: initialValues,
                                         initialBarcode: initialBarcode, onEdit: onEdit, onCreate: onCreate)
            }
        }
        .navigationTitle(navigationTitle)
        .alertError($alertError)
        .if(isSheet, transform: { view in
            view.toolbar {
                toolbarContent
            }
        })
        .task {
            await loadMissingData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: { dismiss() }).bold()
        }
    }

    func loadMissingData() async {
        switch mode {
        case let .edit(initialProduct), let .editSuggestion(initialProduct):
            await loadValuesFromExistingProduct(initialProduct, categories: appDataEnvironmentModel.categories)
        case let .addToBrand(brand):
            loadFromBrand(brand, categories: appDataEnvironmentModel.categories)
        case let .addToSubBrand(brand, subBrand):
            loadFromSubBrand(brand: brand, subBrand: subBrand, categories: appDataEnvironmentModel.categories)
        case .new:
            initialValues = ProductMutationInitialValues(
                category: appDataEnvironmentModel.categories.first(where: { $0.name == "beverage" })
            )
        }
    }

    func loadFromBrand(
        _ brand: Brand.JoinedSubBrandsProductsCompany,
        categories: [Models.Category.JoinedSubcategoriesServingStyles]
    ) {
        initialValues = ProductMutationInitialValues(
            category: categories.first(where: { $0.name == "beverage" }),
            brandOwner: brand.brandOwner,
            brand: Brand.JoinedSubBrands(
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
        )
    }

    func loadFromSubBrand(
        brand: Brand.JoinedSubBrandsProductsCompany,
        subBrand: SubBrand.JoinedProduct,
        categories: [Models.Category.JoinedSubcategoriesServingStyles]
    ) {
        let subBrandsFromBrand = brand.subBrands
            .map { subBrand in SubBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified) }
        initialValues = ProductMutationInitialValues(
            category: categories.first(where: { $0.name == "beverage" }),
            brandOwner: brand.brandOwner,
            brand: Brand.JoinedSubBrands(
                id: brand.id,
                name: brand.name,
                logoFile: brand.logoFile,
                isVerified: brand.isVerified,
                subBrands: subBrandsFromBrand
            ),
            subBrand: subBrandsFromBrand.first(where: { $0.id == subBrand.id })
        )
    }

    func loadValuesFromExistingProduct(
        _ initialProduct: Product.Joined,
        categories: [Models.Category.JoinedSubcategoriesServingStyles]
    ) async {
        switch await repository.brand
            .getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id)
        {
        case let .success(brandsWithSubBrands):
            let category = categories.first(where: { $0.id == initialProduct.category.id })
            initialValues = ProductMutationInitialValues(
                subcategories: initialProduct.subcategories
                    .map { sub in Subcategory(id: sub.id, name: sub.name, isVerified: sub.isVerified) },
                category: category,
                brandOwner: initialProduct.subBrand.brand.brandOwner,
                brand: Brand.JoinedSubBrands(
                    id: initialProduct.subBrand.brand.id,
                    name: initialProduct.subBrand.brand.name,
                    logoFile: initialProduct.subBrand.brand.logoFile,
                    isVerified: initialProduct.subBrand.brand.isVerified,
                    subBrands: brandsWithSubBrands
                        .first(where: { $0.id == initialProduct.subBrand.brand.id })?.subBrands ?? []
                ),
                subBrand: initialProduct.subBrand,
                name: initialProduct.name,
                description: initialProduct.description.orEmpty,
                isDiscontinued: initialProduct.isDiscontinued,
                logoFile: initialProduct.logoFile
            )
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Failed to load brand owner for product '\(initialProduct.id)'. Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}

private struct ProductMutationInitialValues {
    let subcategories: [Subcategory]
    let category: Models.Category.JoinedSubcategoriesServingStyles?
    let brandOwner: Company?
    let brand: Brand.JoinedSubBrands?
    let subBrand: SubBrandProtocol?
    let name: String
    let description: String
    let isDiscontinued: Bool
    let hasSubBrand: Bool
    let logoFile: String?

    init(
        subcategories: [Subcategory] = [],
        category: Models.Category.JoinedSubcategoriesServingStyles? = nil,
        brandOwner: Company? = nil,
        brand: Brand.JoinedSubBrands? = nil,
        subBrand: SubBrandProtocol? = nil,
        name: String = "",
        description: String = "",
        isDiscontinued: Bool = false,
        logoFile: String? = nil
    ) {
        self.subcategories = subcategories
        self.category = category
        self.brandOwner = brandOwner
        self.brand = brand
        self.subBrand = subBrand
        self.name = name
        self.description = description
        self.isDiscontinued = isDiscontinued
        hasSubBrand = subBrand?.name != nil
        self.logoFile = logoFile
    }
}

struct ProductMutationInnerView: View {
    private let logger = Logger(category: "ProductMutationInnerView")
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(SheetManager.self) private var sheetEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Focusable?
    @State private var alertError: AlertError?
    @State private var subcategories: Set<Int>
    @State private var category: Int?
    @State private var brandOwner: Company? {
        didSet {
            brand = nil
            subBrand = nil
            hasSubBrand = false
        }
    }

    @State private var brand: Brand.JoinedSubBrands?
    @State private var subBrand: SubBrandProtocol?
    @State private var name: String
    @State private var description: String
    @State private var isDiscontinued = false
    @State private var isSuccess = false
    @State private var hasSubBrand: Bool {
        didSet {
            if oldValue == true {
                subBrand = nil
            }
        }
    }

    @State private var barcode: Barcode?

    let mode: Mode
    let isSheet: Bool
    let onEdit: (() async -> Void)?
    let onCreate: ((_ product: Product.Joined) async -> Void)?

    fileprivate init(
        mode: Mode,
        isSheet: Bool,
        initialValues: ProductMutationInitialValues,
        initialBarcode: Barcode? = nil,
        onEdit: (() async -> Void)? = nil,
        onCreate: ((_ product: Product.Joined) -> Void)? = nil
    ) {
        self.mode = mode
        self.isSheet = isSheet
        _barcode = State(wrappedValue: initialBarcode)
        self.onEdit = onEdit
        self.onCreate = onCreate
        _category = State(initialValue: initialValues.category?.id)
        _subcategories = State(initialValue: Set(initialValues.subcategories.map(\.id)))
        _brandOwner = State(initialValue: initialValues.brandOwner)
        _brand = State(initialValue: initialValues.brand)
        _hasSubBrand = State(initialValue: initialValues.hasSubBrand)
        _subBrand = State(initialValue: initialValues.subBrand)
        _name = State(initialValue: initialValues.name)
        _description = State(initialValue: initialValues.description)
        _isDiscontinued = State(initialValue: initialValues.isDiscontinued)
    }

    var showBarcodeSection: Bool {
        switch mode {
        case .addToBrand, .addToSubBrand, .new:
            true
        default:
            false
        }
    }

    var body: some View {
        Form {
            categorySection
            brandSection
            productSection
            action
        }
        .sensoryFeedback(.success, trigger: isSuccess)
        .onChange(of: category) {
            subcategories = []
        }
        .onChange(of: brand) {
            hasSubBrand = false
            if let brand {
                subBrand = brand.subBrands.first(where: { $0.name == nil })
            }
        }
    }

    private var action: some View {
        ProgressButton(mode.doneLabel, action: {
            await primaryAction()
        })
        .fontWeight(.medium)
        .disabled(!isValid())
    }

    private var selectedCategory: Models.Category.JoinedSubcategoriesServingStyles? {
        appDataEnvironmentModel.categories.first(where: { $0.id == category })
    }

    private var selectedSubcategories: [Subcategory] {
        selectedCategory?.subcategories
            .filter { subcategories.contains($0.id) } ?? []
    }

    private var categorySection: some View {
        Section {
            RouterLink(
                selectedCategory?.name ?? "Pick a category",
                sheet: .categoryPickerSheet(category: $category)
            )

            Button(action: {
                if let selectedCategory {
                    sheetEnvironmentModel.navigate(sheet: .subcategory(
                        subcategories: $subcategories,
                        category: selectedCategory
                    ))
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
                label: "Brand Owner",
                selection: brandOwner?.name,
                sheet: .companySearch(onSelect: { company in
                    brandOwner = company
                })
            )

            if let brandOwner {
                PickerLinkRow(
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

            if showBarcodeSection {
                RouterLink(
                    barcode == nil ? "Add Barcode" : "Barcode Added!",
                    sheet: .barcodeScanner(onComplete: { barcode in
                        self.barcode = barcode
                    })
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

    func isValid() -> Bool {
        category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal)
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

extension ProductMutationInnerView {
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
    }

    enum Focusable {
        case name, description
    }
}

struct PickerLinkRow: View {
    let label: String
    let selection: String?
    let sheet: Sheet

    var body: some View {
        RouterLink(sheet: sheet) {
            HStack {
                Text(label)
                Spacer()
                if let selection {
                    Text(selection)
                }
            }
        }
    }
}
