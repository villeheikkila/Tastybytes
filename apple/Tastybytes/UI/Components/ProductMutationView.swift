import CachedAsyncImage
import OSLog
import SwiftUI

struct ProductMutationView: View {
    private let logger = Logger(category: "ProductMutationView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(AppDataManager.self) private var appDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var initialValues: ProductMutationInitialValues?

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
            return "Add Product"
        case .edit:
            return "Edit Product"
        case .editSuggestion:
            return "Edit Suggestion"
        }
    }

    var body: some View {
        VStack {
            if let initialValues {
                ProductMutationInnerView(mode: mode, initialValues: initialValues,
                                         initialBarcode: initialBarcode, onEdit: onEdit, onCreate: onCreate)
            }
        }
        .navigationTitle(navigationTitle)
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
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Cancel", role: .cancel, action: { dismiss() }).bold()
        }
    }

    func loadMissingData() async {
        switch mode {
        case let .edit(initialProduct), let .editSuggestion(initialProduct):
            await loadValuesFromExistingProduct(initialProduct, categories: appDataManager.categories)
        case let .addToBrand(brand):
            loadFromBrand(brand, categories: appDataManager.categories)
        case let .addToSubBrand(brand, subBrand):
            loadFromSubBrand(brand: brand, subBrand: subBrand, categories: appDataManager.categories)
        case .new:
            initialValues = ProductMutationInitialValues(
                category: appDataManager.categories.first(where: { $0.name == "beverage" })
            )
        }
    }

    func loadFromBrand(
        _ brand: Brand.JoinedSubBrandsProductsCompany,
        categories: [Category.JoinedSubcategoriesServingStyles]
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
        categories: [Category.JoinedSubcategoriesServingStyles]
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
        categories: [Category.JoinedSubcategoriesServingStyles]
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
                logoFile: initialProduct.logoFile
            )
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to load brand owner for product '\(initialProduct.id)'. error: \(error)")
        }
    }
}

private struct ProductMutationInitialValues {
    let subcategories: [Subcategory]
    let category: Category.JoinedSubcategoriesServingStyles?
    let brandOwner: Company?
    let brand: Brand.JoinedSubBrands?
    let subBrand: SubBrandProtocol?
    let name: String
    let description: String
    let hasSubBrand: Bool
    let logoFile: String?

    init(
        subcategories: [Subcategory] = [],
        category: Category.JoinedSubcategoriesServingStyles? = nil,
        brandOwner: Company? = nil,
        brand: Brand.JoinedSubBrands? = nil,
        subBrand: SubBrandProtocol? = nil,
        name: String = "",
        description: String = "",
        logoFile: String? = nil
    ) {
        self.subcategories = subcategories
        self.category = category
        self.brandOwner = brandOwner
        self.brand = brand
        self.subBrand = subBrand
        self.name = name
        self.description = description
        hasSubBrand = subBrand?.name != nil
        self.logoFile = logoFile
    }
}

struct ProductMutationInnerView: View {
    private let logger = Logger(category: "ProductMutationInnerView")
    @Environment(Repository.self) private var repository
    @Environment(ProfileManager.self) private var profileManager
    @Environment(Router.self) private var router
    @Environment(SheetManager.self) private var sheetManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(AppDataManager.self) private var appDataManager
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Focusable?
    @State private var subcategories: [Subcategory]
    @State private var category: Category.JoinedSubcategoriesServingStyles?
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
    @State private var hasSubBrand: Bool {
        didSet {
            if oldValue == true {
                subBrand = nil
            }
        }
    }

    @State private var barcode: Barcode?

    let mode: Mode
    let onEdit: (() async -> Void)?
    let onCreate: ((_ product: Product.Joined) async -> Void)?

    fileprivate init(
        mode: Mode,
        initialValues: ProductMutationInitialValues,
        initialBarcode: Barcode? = nil,
        onEdit: (() async -> Void)? = nil,
        onCreate: ((_ product: Product.Joined) -> Void)? = nil
    ) {
        self.mode = mode
        _barcode = State(wrappedValue: initialBarcode)
        self.onEdit = onEdit
        self.onCreate = onCreate
        _category = State(initialValue: initialValues.category)
        _subcategories = State(initialValue: initialValues.subcategories)
        _brandOwner = State(initialValue: initialValues.brandOwner)
        _brand = State(initialValue: initialValues.brand)
        _hasSubBrand = State(initialValue: initialValues.hasSubBrand)
        _subBrand = State(initialValue: initialValues.subBrand)
        _name = State(initialValue: initialValues.name)
        _description = State(initialValue: initialValues.description)
    }

    var showBarcodeSection: Bool {
        switch mode {
        case .addToBrand, .addToSubBrand, .new:
            return true
        default:
            return false
        }
    }

    var body: some View {
        Form {
            categorySection
            brandSection
            productSection
            action
        }
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

    private var categorySection: some View {
        Section {
            RouterLink(
                category?.name ?? "Pick a category",
                sheet: .categoryPickerSheet(category: $category)
            )

            Button(action: {
                if let category {
                    sheetManager.navigate(sheet: .subcategory(
                        subcategories: $subcategories,
                        category: category
                    ))
                }
            }, label: {
                HStack {
                    if subcategories.isEmpty {
                        Text("Subcategories")
                    } else {
                        HStack(spacing: 4) {
                            ForEach(subcategories) { subcategory in
                                SubcategoryLabelView(subcategory: subcategory)
                            }
                        }
                    }
                }
            }).disabled(category == nil)
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
            RouterLink(brandOwner?.name ?? "Company", sheet: .companySearch(onSelect: { company in
                brandOwner = company
            }))

            if let brandOwner {
                RouterLink(
                    brand?.name ?? "Brand",
                    sheet: .brand(brandOwner: brandOwner, brand: $brand, mode: .select)
                )
            }

            if brand != nil {
                Toggle("Has sub-brand?", isOn: .init(get: {
                    hasSubBrand
                }, set: { newValue in
                    hasSubBrand = newValue
                    if newValue == false {
                        subBrand = nil
                    }
                }))
            }

            if hasSubBrand, let brand {
                RouterLink(
                    subBrand?.name ?? "Sub-brand",
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
            HStack {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .name)
                    .overlay(
                        ScanTextButton(text: $name),
                        alignment: .trailing
                    )
            }
            TextField("Description (optional)", text: $description)
                .focused($focusedField, equals: .description)
                .overlay(
                    ScanTextButton(text: $description),
                    alignment: .trailing
                )

            if showBarcodeSection {
                RouterLink(
                    barcode == nil ? "Add Barcode" : "Barcode Added!",
                    sheet: .barcodeScanner(onComplete: { barcode in
                        self.barcode = barcode
                    })
                )
            }
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
            categoryId: category.id,
            brandId: brandId,
            subBrandId: subBrand?.id,
            subCategoryIds: subcategories.map(\.id),
            barcode: barcode
        )
        switch await repository.product.create(newProductParams: newProductParams) {
        case let .success(newProduct):
            await MainActor.run {
                feedbackManager.trigger(.notification(.success))
                router.navigate(screen: .product(newProduct))
                dismiss()
            }
            await onSuccess(newProduct)
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to create new product. error: \(error)")
        }
    }

    func createProductEditSuggestion(product: Product.Joined) async {
        guard let subBrand, let category else { return }
        let editSuggestion = Product.EditSuggestionRequest(
            id: product.id,
            name: name,
            description: description,
            subBrand: subBrand,
            category: category
        )

        let diffFromCurrent = editSuggestion.diff(from: product)
        guard let diffFromCurrent else {
            feedbackManager.toggle(.warning("There is nothing to edit"))
            return
        }

        switch await repository.product
            .createUpdateSuggestion(productEditSuggestionParams: diffFromCurrent)
        {
        case .success:
            await MainActor.run {
                dismiss()
                feedbackManager.toggle(.success("Edit suggestion sent!"))
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to create product edit suggestion for '\(product.id)'. error: \(error)")
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
            categoryId: category.id,
            subBrandId: subBrandWithNil.id,
            subcategories: subcategories
        )

        switch await repository.product.editProduct(productEditParams: productEditParams) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            dismiss()
            if let onEdit {
                await onEdit()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to edit product '\(product.id)'. error: \(error)")
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
                return "Edit"
            case .editSuggestion:
                return "Submit"
            case .new, .addToBrand, .addToSubBrand:
                return "Create"
            }
        }
    }

    enum Focusable {
        case name, description
    }
}
