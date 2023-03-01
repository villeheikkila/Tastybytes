import SwiftUI

struct AddProductView: View {
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var hapticManager: HapticManager
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
            hapticManager.trigger(of: .notification(.success))
            if let onEdit {
              onEdit()
            }
          })
        case .new:
          await viewModel.createProduct(onSuccess: { product in
            hapticManager.trigger(of: .notification(.success))
            router.navigate(to: .product(product), resetStack: true)
          })
        case .addToBrand:
          await viewModel.createProduct(onSuccess: { product in
            hapticManager.trigger(of: .notification(.success))
            if let onCreate {
              onCreate(product)
            }
          })
        }
      }, label: {
        Text(viewModel.mode.doneLabel)
      }).disabled(viewModel.isLoading || !viewModel.isValid())
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .subcategories:
          if let category = viewModel.category {
            SubcategorySheet(
              subcategories: $viewModel.subcategories,
              category: category,
              onCreate: { newSubcategoryName in
                viewModel.createSubcategory(newSubcategoryName: newSubcategoryName)
              }
            )
          }
        case .brandOwner:
          CompanySearchSheet(viewModel.client, onSelect: { company, createdNew in
            viewModel.setBrandOwner(company)
            if createdNew {
              toastManager.toggle(.success(viewModel.getToastText(.createdCompany)))
            }
            viewModel.dismissSheet()
          })
        case .brand:
          if let brandOwner = viewModel.brandOwner {
            BrandSheet(viewModel.client, brandOwner: brandOwner, mode: .select, onSelect: { brand, createdNew in
              if createdNew {
                toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
              }
              viewModel.setBrand(brand: brand)
            })
          }

        case .subBrand:
          if let brand = viewModel.brand {
            SubBrandSheet(viewModel.client, brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
              if createdNew {
                toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
              }
              viewModel.subBrand = subBrand
              viewModel.dismissSheet()

            })
          }
        case .barcode:
          BarcodeScannerSheet(onComplete: { barcode in
            viewModel.barcode = barcode
          })
        }
      }.if(sheet == .barcode, transform: { view in view.presentationDetents([.medium]) })
    }
    .task {
      viewModel.loadMissingData()
    }
  }

  private var categorySection: some View {
    Section {
      if !viewModel.categories.isEmpty {
        Picker("Category", selection: $viewModel.category) {
          Text("None").tag(Category.JoinedSubcategories?(nil))
            .fontWeight(.medium)
          ForEach(viewModel.categories) { category in
            Text(category.name.label)
              .fontWeight(.medium)
              .tag(Optional(category))
          }
        }
      }

      Button(action: { viewModel.setActiveSheet(.subcategories) }, label: {
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
      Button(action: { viewModel.setActiveSheet(.brandOwner) }, label: {
        Text(viewModel.brandOwner?.name ?? "Company")
          .fontWeight(.medium)
      })
      if viewModel.brandOwner != nil {
        Button(action: { viewModel.setActiveSheet(.brand) }, label: {
          Text(viewModel.brand?.name ?? "Brand")
            .fontWeight(.medium)
        })
        .disabled(viewModel.brandOwner == nil)
      }

      if viewModel.brand != nil {
        Toggle("Has sub-brand?", isOn: $viewModel.hasSubBrand)
      }

      if viewModel.hasSubBrand {
        Button(action: { viewModel.setActiveSheet(.subBrand) }, label: {
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
        Button(action: { viewModel.setActiveSheet(.barcode) }, label: {
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
