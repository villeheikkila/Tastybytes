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
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresentedInSheet) var isPresentedInSheet
    @FocusState private var focusedField: Focusable?
    @State private var primaryActionTask: Task<Void, Never>?
    // Sheet status
    @State private var isSuccess = false
    @State private var state: ScreenState = .loading
    // Product details
    @State private var subcategories = [Subcategory]()
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
    @State private var logos: [ImageEntity] = []

    let mode: Mode

    init(mode: Mode, initialBarcode: Barcode? = nil) {
        self.mode = mode
        _barcode = State(initialValue: initialBarcode)
    }

    private var selectedCategory: Models.Category.JoinedSubcategoriesServingStyles? {
        appEnvironmentModel.categories.first(where: { $0.id == category })
    }

    private var isValid: Bool {
        category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal)
    }

    var body: some View {
        Form {
            if state == .populated {
                populatedContent
            }
        }
        .scrollContentBackground(isPresentedInSheet ? .hidden : .visible)
        .navigationTitle(mode.navigationTitle)
        .foregroundColor(.primary)
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "", errorAction: {
                await initialize()
            })
        }
        .toolbar {
            toolbarContent
        }
        .task {
            await initialize()
        }
        .sensoryFeedback(.success, trigger: isSuccess)
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

    @ViewBuilder private var populatedContent: some View {
        categorySection
        brandSection
        productSection
        if case .edit = mode {
            EditLogoSection(logos: logos, onUpload: { imageData in
                await uploadData(data: imageData)
            }, onDelete: { imageEntity in
                await deleteLogo(entity: imageEntity)
            })
        }
    }

    private var categorySection: some View {
        Section {
            Button(
                selectedCategory?.name ?? String(localized: "product.mutation.pickCategory.label"),
                action: {
                    router.openSheet(.categoryPickerSheet(category: $category))
                }
            )

            Button(action: {
                if let selectedCategory {
                    router.openSheet(.subcategory(
                        subcategories: $subcategories,
                        category: selectedCategory
                    ))
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
                sheet: .companySearch(onSelect: { company in
                    brandOwner = company
                })
            )

            if let brandOwner {
                PickerLinkRow(
                    label: "brand.title",
                    selection: brand?.name,
                    sheet: .brand(brandOwner: brandOwner, brand: $brand, mode: .select)
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
                    sheet: .subBrand(brandWithSubBrands: brand, subBrand: $subBrand)
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
            ScanTextField(title: "product.name.placeholder", text: $name)
                .focused($focusedField, equals: .name)
            ScanTextField(title: "product.description.placeholder", text: $description)
                .focused($focusedField, equals: .description)

            if mode.showBarcodeSection {
                Button(
                    barcode == nil ? "product.barcode.add.label" : "product.barcode.added.label",
                    action: { router.openSheet(.barcodeScanner(onComplete: { barcode in
                        self.barcode = barcode
                    })) }
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

    func primaryAction() async {
        guard primaryActionTask != nil else { return }
        defer { primaryActionTask = nil }
        switch mode {
        case let .editSuggestion(product):
            guard let subBrand, let selectedCategory else { return }
            let diffFromCurrent = Product.EditSuggestionRequest(
                id: product.id,
                name: name,
                description: description,
                subBrand: subBrand,
                category: selectedCategory,
                isDiscontinued: isDiscontinued
            ).diff(from: product)
            guard let diffFromCurrent else {
                feedbackEnvironmentModel.toggle(.warning("product.editSuggestion.nothingToEdit.toast"))
                return
            }
            switch await repository.product.createUpdateSuggestion(productEditSuggestionParams: diffFromCurrent) {
            case .success:
                dismiss()
                feedbackEnvironmentModel.toggle(.success("product.editSuggestion.success.toast"))
            case let .failure(error):
                guard !error.isCancelled else { return }
                router.openAlert(.init(title: "product.error.failedToCreateEditSuggestion.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }))
                logger.error("Failed to create product edit suggestion for '\(product.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .edit(product, onEdit):
            guard let category, let brand else { return }
            let subBrandWithNil = subBrand == nil ? brand.subBrands.first(where: { $0.name == nil }) : subBrand
            guard let subBrandWithNil else { return }
            switch await repository.product.editProduct(productEditParams: .init(
                productId: product.id,
                name: name,
                description: description,
                categoryId: category,
                subBrandId: subBrandWithNil.id,
                subcategories: Array(subcategories),
                isDiscontinued: isDiscontinued
            )) {
            case let .success(updatedProduct):
                isSuccess = true
                if let onEdit {
                    await onEdit(updatedProduct)
                }
                dismiss()
            case let .failure(error):
                guard !error.isCancelled else { return }
                router.openAlert(.init(title: "product.error.failedToUpdate.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }))
                logger.error("Failed to edit product '\(product.id)'. Error: \(error) (\(#file):\(#line))")
            }
        case let .new(onCreate), let .addToBrand(_, onCreate), let .addToSubBrand(_, _, onCreate):
            guard let category, let brandId = brand?.id else { return }
            switch await repository.product.create(newProductParams: .init(
                name: name,
                description: description,
                categoryId: category,
                brandId: brandId,
                subBrandId: subBrand?.id,
                subcategories: Array(subcategories),
                isDiscontinued: isDiscontinued,
                barcode: barcode
            )) {
            case let .success(newProduct):
                isSuccess = true
                if isPresentedInSheet {
                    dismiss()
                }
                if let onCreate {
                    await onCreate(newProduct)
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                router.openAlert(.init(title: "product.error.failedToCreate.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }))
                logger.error("Failed to create new product. Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    func initialize() async {
        switch mode {
        case let .edit(initialProduct, _), let .editSuggestion(initialProduct):
            switch await repository.brand.getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id) {
            case let .success(brandsWithSubBrands):
                category = initialProduct.category.id
                subcategories = initialProduct.subcategories.map { .init(subcategory: $0) }
                brandOwner = initialProduct.subBrand.brand.brandOwner
                brand = brandsWithSubBrands.first(where: { $0.id == initialProduct.subBrand.brand.id })
                if initialProduct.subBrand.name != nil {
                    hasSubBrand = true
                }
                subBrand = initialProduct.subBrand
                name = initialProduct.name
                description = initialProduct.description.orEmpty
                isDiscontinued = initialProduct.isDiscontinued
                logos = initialProduct.logos
                state = .populated
            case let .failure(error):
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
        case .new:
            state = .populated
        }
    }

    func deleteLogo(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .productLogos, entity: entity) {
        case .success:
            withAnimation {
                logos.remove(object: entity)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadData(data: Data) async {
        guard case let .edit(product, _) = mode else { return }
        switch await repository.product.uploadLogo(productId: product.id, data: data) {
        case let .success(imageEntity):
            logos.append(imageEntity)
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
        case let .failure(error):
            logger.error("Uploading of a product logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension ProductMutationView {
    enum Mode: Equatable {
        case new(onCreate: ProductCallback? = nil), edit(Product.Joined, onEdit: ProductCallback?), editSuggestion(Product.Joined),
             addToBrand(Brand.JoinedSubBrandsProductsCompany, onCreate: ProductCallback?),
             addToSubBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct, onCreate: ProductCallback?)

        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.new(_), .new(_)):
                false
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
