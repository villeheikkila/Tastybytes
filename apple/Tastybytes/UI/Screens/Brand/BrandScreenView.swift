import CachedAsyncImage
import SwiftUI

struct BrandScreenView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand))
  }

  var body: some View {
    List {
      if let summary = viewModel.summary, summary.averageRating != nil {
        Section {
          SummaryView(summary: summary)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
      }
      ForEach(viewModel.sortedSubBrands, id: \.self) { subBrand in
        Section {
          ForEach(subBrand.products, id: \.id) { product in
            NavigationLink(value: Route.product(Product
                .Joined(
                  product: product,
                  subBrand: subBrand,
                  brand: viewModel.brand
                ))) {
              VStack {
                HStack {
                  CategoryView(category: product.category, subcategories: product.subcategories)
                  Spacer()
                }
                HStack {
                  Text(joinOptionalStrings([viewModel.brand.name, subBrand.name, product.name]))
                    .lineLimit(nil)
                  Spacer()
                }
                if let description = product.description {
                  HStack {
                    Text(description)
                      .font(.caption)
                    Spacer()
                  }
                }
              }
              .contextMenu {
                if profileManager.hasPermission(.canMergeProducts) {
                  Button(action: { viewModel.productToMerge = product }, label: {
                    Text("Merge product to...")
                  })
                }

                if profileManager.hasPermission(.canDeleteProducts) {
                  Button(role: .destructive, action: { viewModel.productToDelete = product }, label: {
                    Label("Delete", systemImage: "trash.fill")
                      .foregroundColor(.red)
                  })
                  .disabled(product.isVerified)
                }
              }
            }
          }
        } header: {
          HStack {
            if let name = subBrand.name {
              Text(name)
            }
            Spacer()
            Menu {
              if profileManager.hasPermission(.canEditBrands) {
                Button(action: { viewModel.editSubBrand = subBrand }, label: {
                  Label("Edit", systemImage: "pencil")
                })
              }

              if subBrand.isVerified {
                Button(action: { viewModel.toUnverifySubBrand = subBrand }, label: {
                  Label("Verified", systemImage: "checkmark.circle")
                })
              } else if profileManager.hasPermission(.canVerify) {
                Button(action: { viewModel.verifySubBrand(subBrand, isVerified: true) }, label: {
                  Label("Verify", systemImage: "checkmark")
                })
              } else {
                Label("Not verified", systemImage: "x.circle")
              }

              if profileManager.hasPermission(.canDeleteBrands) {
                Button(role: .destructive, action: { viewModel.toDeleteSubBrand = subBrand }, label: {
                  Label("Delete", systemImage: "trash.fill")
                })
                .disabled(subBrand.isVerified)
              }
            } label: {
              Image(systemName: "ellipsis")
                .frame(width: 24, height: 24)
            }
          }
        }
        .headerProminence(.increased)
      }
    }
    .listStyle(.grouped)
    .refreshable {
      viewModel.refresh()
    }
    .task {
      await viewModel.getSummary()
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editBrand:
          EditBrandSheetView(viewModel.client, brand: viewModel.brand) {
            viewModel.refresh()
          }
        case .editSubBrand:
          if let editSubBrand = viewModel.editSubBrand {
            EditSubBrandSheetView(viewModel.client, brand: viewModel.brand, subBrand: editSubBrand) {
              viewModel.refresh()
            }
          }
        case .mergeProduct:
          if let productToMerge = viewModel.productToMerge {
            MergeSheetView(viewModel.client, productToMerge: productToMerge)
          }
        case .addProduct:
          DismissableSheet(title: "Add Product") {
            AddProductView(viewModel.client, mode: .addToBrand(viewModel.brand), onCreate: { product in
              viewModel.activeSheet = nil
              router.navigate(to: .product(product), resetStack: false)
            })
          }
        }
      }
    }
    .navigationTitle(viewModel.brand.name)
    .navigationBarItems(trailing: navigationBarMenu)
    .confirmationDialog("Unverify Sub-brand",
                        isPresented: $viewModel.showSubBrandUnverificationConfirmation,
                        presenting: viewModel.toUnverifySubBrand) { presenting in
      Button("Unverify \(presenting.name ?? "default") sub-brand", action: {
        viewModel.verifySubBrand(presenting, isVerified: false)
        hapticManager.trigger(of: .notification(.success))
      })
    }
    .confirmationDialog("Unverify Brand",
                        isPresented: $viewModel.showBrandUnverificationConfirmation,
                        presenting: viewModel.brand) { presenting in
      Button("Unverify \(presenting.name) brand", action: {
        viewModel.verifyBrand(isVerified: false)
        hapticManager.trigger(of: .notification(.success))
      })
    }
    .confirmationDialog("Delete Sub-brand",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        presenting: viewModel.toDeleteSubBrand) { presenting in
      Button(
        "Delete \(presenting.name ?? "default sub-brand") and all related products",
        role: .destructive,
        action: {
          viewModel.deleteSubBrand()
          hapticManager.trigger(of: .notification(.success))
        }
      )
    }
    .confirmationDialog("Delete Brand Confirmation",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        presenting: viewModel.brand) { presenting in
      Button("Delete \(presenting.name) Brand", role: .destructive, action: {
        viewModel.deleteBrand(onDelete: {
          router.reset()
          hapticManager.trigger(of: .notification(.success))
        })
      })
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.brand(id: viewModel.brand.id).url)

      if profileManager.hasPermission(.canCreateProducts) {
        Button(action: { viewModel.setActiveSheet(.addProduct) }, label: {
          Label("Add Product", systemImage: "plus")
        })
      }

      Divider()

      if profileManager.hasPermission(.canEditBrands) {
        Button(action: { viewModel.setActiveSheet(.editBrand) }, label: {
          Label("Edit", systemImage: "pencil")
        })
      }

      if viewModel.brand.isVerified {
        Button(action: { viewModel.showBrandUnverificationConfirmation = true }, label: {
          Label("Verified", systemImage: "checkmark.circle")
        })
      } else if profileManager.hasPermission(.canVerify) {
        Button(action: { viewModel.verifyBrand(isVerified: true) }, label: {
          Label("Verify", systemImage: "checkmark")
        })
      } else {
        Label("Not verified", systemImage: "x.circle")
      }

      if profileManager.hasPermission(.canDeleteBrands) {
        Button(role: .destructive, action: { viewModel.showDeleteBrandConfirmationDialog.toggle() }, label: {
          Label("Delete", systemImage: "trash.fill")
        })
        .disabled(viewModel.brand.isVerified)
      }
    } label: {
      Image(systemName: "ellipsis")
    }
  }
}
