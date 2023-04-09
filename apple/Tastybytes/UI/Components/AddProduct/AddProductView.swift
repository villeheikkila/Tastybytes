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

  let onEdit: (() -> Void)?
  let onCreate: ((_ product: Product.Joined) -> Void)?

  init(
    _ client: Client,
    mode: Mode,
    initialBarcode: Barcode? = nil,
    onEdit: (() -> Void)? = nil,
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

      ProgressButton(action: {
        switch viewModel.mode {
        case .editSuggestion:
          await viewModel.createProductEditSuggestion(onSuccess: {
            toastManager.toggle(.success("Edit suggestion sent!"))
          })
        case .edit:
          await viewModel.editProduct(onSuccess: {
            hapticManager.trigger(.notification(.success))
            if let onEdit {
              onEdit()
            }
          })
        case .new:
          await viewModel.createProduct(onSuccess: { product in
            hapticManager.trigger(.notification(.success))
            router.navigate(to: .product(product), resetStack: true)
          })
        case .addToBrand:
          await viewModel.createProduct(onSuccess: { product in
            hapticManager.trigger(.notification(.success))
            if let onCreate {
              onCreate(product)
            }
          })
        }
      }, label: {
        Text(viewModel.mode.doneLabel)
      }).disabled(viewModel.isLoading || !viewModel.isValid())
    }
    .task {
      await viewModel.loadMissingData(categories: appDataManager.categories)
    }
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
          router.openSheet(.subcategory(
            subcategories: $viewModel.subcategories,
            category: category,
            onCreate: { newSubcategoryName in
              viewModel.createSubcategory(newSubcategoryName: newSubcategoryName, onCreate: {
                Task { await appDataManager.initialize() }
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
      })
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
      Button(action: { router.openSheet(.companySearch(onSelect: { company, createdNew in
        viewModel.setBrandOwner(company)
        if createdNew {
          toastManager.toggle(.success(viewModel.getToastText(.createdCompany)))
        }
      })) }, label: {
        Text(viewModel.brandOwner?.name ?? "Company")
          .fontWeight(.medium)
      })
      if let brandOwner = viewModel.brandOwner {
        Button(action: { router.openSheet(.brand(brandOwner: brandOwner, mode: .select, onSelect: { brand, createdNew in
          if createdNew {
            toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
          }
          viewModel.setBrand(brand: brand)
        }))
        }, label: {
          Text(viewModel.brand?.name ?? "Brand")
            .fontWeight(.medium)
        })
        .disabled(viewModel.brandOwner == nil)
      }

      if viewModel.brand != nil {
        Toggle("Has sub-brand?", isOn: $viewModel.hasSubBrand)
      }

      if viewModel.hasSubBrand, let brand = viewModel.brand {
        Button(action: { router.openSheet(.subBrand(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
          if createdNew {
            toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
          }
          viewModel.subBrand = subBrand
        })) }, label: {
          Text(viewModel.subBrand?.name ?? "Sub-brand")
            .fontWeight(.medium)
        })
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
        Button(action: { router.openSheet(.barcodeScanner(onComplete: { barcode in
          viewModel.barcode = barcode
        })) }, label: {
          Text(viewModel.barcode == nil ? "Add Barcode" : "Barcode Added!")
            .fontWeight(.medium)
        })
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
