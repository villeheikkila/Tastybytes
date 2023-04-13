import CachedAsyncImage
import PhotosUI
import SwiftUI

struct AddProductView: View {
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @StateObject private var viewModel: ViewModel
  @FocusState private var focusedField: Focusable?
  @State private var subcategories: [Subcategory] = []

  let onEdit: (() async -> Void)?
  let onCreate: ((_ product: Product.Joined) async -> Void)?

  init(
    _ client: Client,
    mode: Mode,
    initialBarcode: Barcode? = nil,
    onEdit: (() async -> Void)? = nil,
    onCreate: ((_ product: Product.Joined) -> Void)? = nil
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, mode: mode, barcode: initialBarcode))
    self.onEdit = onEdit
    self.onCreate = onCreate
  }

  var body: some View {
    Form {
      if profileManager.hasPermission(.canAddProductLogo) {
        logoSection
      }
      categorySection
      brandSection
      productSection
      action
    }
    .onChange(of: subcategories, perform: { newValue in
      viewModel.subcategories = newValue
    })
    .task {
      await viewModel.loadMissingData(categories: appDataManager.categories)
    }
  }

  private var action: some View {
    ProgressButton(viewModel.mode.doneLabel, action: {
      switch viewModel.mode {
      case .editSuggestion:
        await viewModel.createProductEditSuggestion(onSuccess: {
          toastManager.toggle(.success("Edit suggestion sent!"))
        })
      case .edit:
        await viewModel.editProduct(onSuccess: {
          hapticManager.trigger(.notification(.success))
          if let onEdit {
            await onEdit()
          }
        })
      case .new:
        await viewModel.createProduct(onSuccess: { product in
          hapticManager.trigger(.notification(.success))
          router.navigate(screen: .product(product), resetStack: true)
        })
      case .addToBrand:
        await viewModel.createProduct(onSuccess: { product in
          hapticManager.trigger(.notification(.success))
          if let onCreate {
            await onCreate(product)
          }
        })
      }
    })
    .fontWeight(.medium)
    .disabled(viewModel.isLoading || !viewModel.isValid())
  }

  private var logoSection: some View {
    Section {
      PhotosPicker(
        selection: $viewModel.selectedLogo,
        matching: .images,
        photoLibrary: .shared()
      ) {
        if let logoFile = viewModel.logoFile, let logoUrl = URL(
          bucketId: Product.getQuery(.logoBucket),
          fileName: logoFile
        ) {
          CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 52, height: 52)
              .accessibility(hidden: true)
          } placeholder: {
            Image(systemName: "photo")
              .accessibility(hidden: true)
          }
        } else {
          Image(systemName: "photo")
            .accessibility(hidden: true)
        }
      }
    }
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
  }

  private var categorySection: some View {
    Section {
      Picker("Category", selection: $viewModel.category) {
        Text("None").tag(Category.JoinedSubcategories?(nil))
          .fontWeight(.medium)
        ForEach(appDataManager.categories) { category in
          Text(category.name)
            .fontWeight(.medium)
            .tag(Optional(category))
        }
      }

      Button(action: {
        if let category = viewModel.category {
          router.navigate(sheet: .subcategory(
            subcategories: $subcategories,
            category: category,
            onCreate: { newSubcategoryName in
              await viewModel.createSubcategory(newSubcategoryName: newSubcategoryName, onCreate: {
                await appDataManager.initialize()
              })
            }
          ))
        }
      }, label: {
        HStack {
          if viewModel.subcategories.isEmpty {
            Text("Subcategories")
              .fontWeight(.medium)
          } else {
            HStack {
              ForEach(viewModel.subcategories) { subcategory in
                ChipView(title: subcategory.name)
              }
            }
          }
        }
      }).disabled(viewModel.category == nil)
    }
    header: {
      Text("Category")
        .fontWeight(.medium)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var brandSection: some View {
    Section {
      RouterLink(viewModel.brandOwner?.name ?? "Company", sheet: .companySearch(onSelect: { company, createdNew in
        viewModel.setBrandOwner(company)
        if createdNew {
          toastManager.toggle(.success(viewModel.getToastText(.createdCompany)))
        }
      }))
      .fontWeight(.medium)

      if let brandOwner = viewModel.brandOwner {
        RouterLink(
          viewModel.brand?.name ?? "Brand",
          sheet: .brand(brandOwner: brandOwner, mode: .select, onSelect: { brand, createdNew in
            if createdNew {
              toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
            }
            viewModel.setBrand(brand: brand)
          })
        )
        .fontWeight(.medium)
        .disabled(viewModel.brandOwner == nil)
      }

      if viewModel.brand != nil {
        Toggle("Has sub-brand?", isOn: $viewModel.hasSubBrand)
      }

      if viewModel.hasSubBrand, let brand = viewModel.brand {
        RouterLink(
          viewModel.subBrand?.name ?? "Sub-brand",
          sheet: .subBrand(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
            if createdNew {
              toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
            }
            viewModel.subBrand = subBrand
          })
        )
        .fontWeight(.medium)
        .disabled(viewModel.brand == nil)
      }

    } header: {
      Text("Brand")
        .fontWeight(.medium)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var productSection: some View {
    Section {
      TextField("Name", text: $viewModel.name)
        .fontWeight(.medium)
        .focused($focusedField, equals: .name)

      TextField("Description (optional)", text: $viewModel.description)
        .fontWeight(.medium)
        .focused($focusedField, equals: .description)

      if viewModel.mode == .new {
        RouterLink(viewModel.barcode == nil ? "Add Barcode" : "Barcode Added!", sheet: .barcodeScanner(onComplete: { barcode in
          viewModel.barcode = barcode
        }))
        .fontWeight(.medium)
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
}
