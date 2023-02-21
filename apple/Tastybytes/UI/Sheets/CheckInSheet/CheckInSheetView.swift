import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct CheckInSheetView: View {
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var hapticManager: HapticManager
  @State private var showPhotoMenu = false
  @FocusState private var focusedField: Focusable?

  let onCreation: ((_ checkIn: CheckIn) -> Void)?
  let onUpdate: ((_ checkIn: CheckIn) -> Void)?
  let action: Action

  init(_ client: Client, product: Product.Joined, onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, product: product, editCheckIn: nil))
    self.onCreation = onCreation
    onUpdate = nil
    action = Action.create
  }

  init(_ client: Client, checkIn: CheckIn,
       onUpdate: @escaping (_ checkIn: CheckIn) -> Void)
  {
    _viewModel = StateObject(wrappedValue: ViewModel(client, product: checkIn.product, editCheckIn: checkIn))
    onCreation = nil
    self.onUpdate = onUpdate
    action = Action.update
  }

  var body: some View {
    Form {
      Section {
        ProductItemView(product: viewModel.product)
          .accessibilityAddTraits(.isButton)
          .onTapGesture {
            self.focusedField = nil
          }

        if viewModel.image != nil || viewModel.editCheckIn?.imageFile != nil {
          HStack {
            Spacer()
            if let image = viewModel.image {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150, alignment: .top)
                .shadow(radius: 4)
                .accessibilityLabel("Image of the check-in")
            } else if let imageUrl = viewModel.editCheckIn?.getImageUrl() {
              CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 150, alignment: .top)
                  .shadow(radius: 4)
                  .accessibilityLabel("Image of the check-in")
              } placeholder: {
                EmptyView()
              }
            }
            Spacer()
          }
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)

      Section {
        TextField("How was it?", text: $viewModel.review, axis: .vertical)
          .focused($focusedField, equals: .review)
        RatingPickerView(rating: $viewModel.rating)
        Button(action: {
          showPhotoMenu.toggle()
        }) {
          Label(
            "\(viewModel.editCheckIn?.getImageUrl() == nil && viewModel.image == nil ? "Add" : "Change") Photo",
            systemImage: "photo"
          )
        }
        Button(action: {
          viewModel.setActiveSheet(.flavors)
        }) {
          if !viewModel.pickedFlavors.isEmpty {
            WrappingHStack(viewModel.pickedFlavors, id: \.self, spacing: .constant(4)) {
              flavor in ChipView(title: flavor.name.capitalized)
            }
          } else {
            Text("Flavors")
          }
        }
      } header: {
        Text("Review")
      }
      .headerProminence(.increased)

      Section {
        if !viewModel.servingStyles.isEmpty {
          Picker(selection: $viewModel.servingStyle) {
            Text("Not Selected").tag(ServingStyle?(nil))
            ForEach(viewModel.servingStyles, id: \.self) { servingStyle in
              Text(servingStyle.name.rawValue.capitalized).tag(Optional(servingStyle))
            }
          } label: {
            Text("Serving Style")
          }
        }

        Button(action: {
          viewModel.setActiveSheet(.manufacturer)
        }) {
          Text(viewModel.manufacturer?.name ?? "Manufactured by")
        }
      }

      Section {
        Button(action: {
          viewModel.setActiveSheet(.friends)
        }) {
          if viewModel.taggedFriends.isEmpty {
            Text("Tag friends")
          } else {
            WrappingHStack(viewModel.taggedFriends, id: \.self) {
              friend in
              AvatarView(avatarUrl: friend.avatarUrl, size: 24, id: friend.id)
            }
          }
        }
      }

      Button(action: {
        viewModel.setActiveSheet(.location)
      }) {
        if let location = viewModel.location {
          HStack {
            Text(location.name)
            if let title = location.title {
              Text(title)
                .foregroundColor(.secondary)
            }
          }
        } else {
          Text("Location")
        }
      }
    }
    .confirmationDialog("Pick a photo", isPresented: $showPhotoMenu) {
      Button(action: {
        viewModel.showCamera.toggle()
      }) {
        Text("Camera")
      }
      Button(action: {
        viewModel.setActiveSheet(.photoPicker)
      }) {
        Text("Photo Gallery")
      }
    } message: {
      Text("Pick a photo")
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .friends:
          FriendSheetView(taggedFriends: $viewModel.taggedFriends)
        case .flavors:
          FlavorSheetView(viewModel.client, pickedFlavors: $viewModel.pickedFlavors)
        case .location:
          LocationSearchView(viewModel.client, onSelect: {
            location in viewModel.setLocation(location)
          })
        case .manufacturer:
          CompanySearchSheet(viewModel.client, onSelect: { company, _ in
            viewModel.setManufacturer(company)
          })
        case .photoPicker:
          LegacyPhotoPicker(onSelection: {
            image in viewModel.setImageFromPicker(pickedImage: image)
          })
        }
      }
    }
    .fullScreenCover(isPresented: $viewModel.showCamera, content: {
      CameraView(onClose: {
        viewModel.showCamera = false
      }, onCapture: {
        image in viewModel.setImageFromCamera(image)
      })
    })
    .navigationBarItems(
      leading: Button(role: .cancel, action: {
        dismiss()
      }) {
        Text("Cancel").bold()
      },
      trailing: ProgressButton(action: {
                                 switch action {
                                 case .create:
                                   if let onCreation {
                                     await viewModel.createCheckIn {
                                       newCheckIn in
                                       onCreation(newCheckIn)
                                     }
                                   }
                                 case .update:
                                   if let onUpdate {
                                     await viewModel.updateCheckIn {
                                       updatedCheckIn in
                                       onUpdate(updatedCheckIn)
                                     }
                                   }
                                 }
                                 hapticManager.trigger(of: .notification(.success))
                                 dismiss()
                               },
                               label: {
                                 Text(action == Action.create ? "Check-in!" : "Update Check-in!")
                                   .bold()
                               })
    )
    .task {
      viewModel.loadInitialData()
    }
  }
}
