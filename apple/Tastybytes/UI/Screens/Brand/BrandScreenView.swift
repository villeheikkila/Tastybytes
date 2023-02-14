import CachedAsyncImage
import SwiftUI

struct BrandScreenView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand))
  }

  var body: some View {
    List {
      ForEach(viewModel.sortedSubBrands, id: \.self) { subBrand in
        Section {
          ForEach(subBrand.products, id: \.id) {
            product in
            NavigationLink(value: Route.product(Product
                .Joined(
                  product: product,
                  subBrand: subBrand,
                  brand: viewModel.brand
                ))) {
              HStack {
                Text(joinOptionalStrings([viewModel.brand.name, subBrand.name, product.name]))
                  .lineLimit(nil)
                Spacer()
              }
              .contextMenu {
                if profileManager.hasPermission(.canMergeProducts) {
                  Button(action: {
                    viewModel.productToMerge = product
                  }) {
                    Text("Merge product to...")
                  }
                }

                if profileManager.hasPermission(.canDeleteProducts) {
                  Button(action: {
                    viewModel.productToDelete = product
                  }) {
                    Label("Delete", systemImage: "trash.fill")
                      .foregroundColor(.red)
                  }
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
                Button(action: {
                  viewModel.editSubBrand = subBrand
                }) {
                  Label("Edit", systemImage: "pencil")
                }
              }

              if subBrand.isVerified {
                Button(action: {
                  viewModel.toUnverifySubBrand = subBrand
                }) {
                  Label("Verified", systemImage: "checkmark.circle")
                }
              } else if profileManager.hasPermission(.canVerify) {
                Button(action: {
                  viewModel.verifySubBrand(subBrand, isVerified: true)
                }) {
                  Label("Verify", systemImage: "checkmark")
                }
              } else {
                Label("Not verified", systemImage: "x.circle")
              }

              if profileManager.hasPermission(.canDeleteBrands) {
                Button(action: {
                  viewModel.toDeleteSubBrand = subBrand
                }) {
                  Label("Delete", systemImage: "trash.fill")
                }
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
    .refreshable {
      viewModel.refresh()
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
          ProductSheetView(viewModel.client, mode: .addToBrand(viewModel.brand), onCreate: {
            product in
            viewModel.activeSheet = nil
            router.navigate(to: Route.product(product), resetStack: false)
          })
        }
      }
    }
    .navigationTitle(viewModel.brand.name)
    .navigationBarItems(trailing: navigationBarMenu)
    .confirmationDialog("Unverify Sub-brand",
                        isPresented: $viewModel.showSubBrandUnverificationConfirmation,
                        presenting: viewModel.toUnverifySubBrand) { presenting in
      Button("Unverify \(presenting.name ?? "default") sub-brand", role: .destructive, action: {
        viewModel.verifySubBrand(presenting, isVerified: false)
      })
    }
    .confirmationDialog("Unverify Brand",
                        isPresented: $viewModel.showBrandUnverificationConfirmation,
                        presenting: viewModel.brand) { presenting in
      Button("Unverify \(presenting.name) brand", role: .destructive, action: {
        viewModel.verifyBrand(isVerified: false)
      })
    }
    .confirmationDialog("Delete Sub-brand",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        presenting: viewModel.toDeleteSubBrand) { presenting in
      Button("Delete \(presenting.name ?? "default sub-brand") and all related products", role: .destructive, action: {
        viewModel.deleteSubBrand()
      })
    }
    .confirmationDialog("Delete Brand Confirmation",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        presenting: viewModel.brand) { presenting in
      Button("Delete \(presenting.name) Brand", role: .destructive, action: {
        viewModel.deleteBrand(onDelete: {
          router.reset()
        })
      })
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.brand(id: viewModel.brand.id).url)

      if profileManager.hasPermission(.canCreateProducts) {
        Button(action: {
          viewModel.setActiveSheet(.addProduct)
        }) {
          Label("Add Product", systemImage: "plus")
        }
      }

      Divider()

      if profileManager.hasPermission(.canEditBrands) {
        Button(action: {
          viewModel.setActiveSheet(.editBrand)
        }) {
          Label("Edit", systemImage: "pencil")
        }
      }

      if viewModel.brand.isVerified {
        Button(action: {
          viewModel.showBrandUnverificationConfirmation = true
        }) {
          Label("Verified", systemImage: "checkmark.circle")
        }
      } else if profileManager.hasPermission(.canVerify) {
        Button(action: {
          viewModel.verifyBrand(isVerified: true)
        }) {
          Label("Verify", systemImage: "checkmark")
        }
      } else {
        Label("Not verified", systemImage: "x.circle")
      }

      if profileManager.hasPermission(.canDeleteBrands) {
        Button(action: {
          viewModel.showDeleteBrandConfirmationDialog.toggle()
        }) {
          Label("Delete", systemImage: "trash.fill")
        }
        .disabled(viewModel.brand.isVerified)
      }
    } label: {
      Image(systemName: "ellipsis")
    }
  }
}
