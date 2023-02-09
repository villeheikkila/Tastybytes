import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct CheckInSheetView: View {
  @StateObject private var viewModel: ViewModel
  @Environment(\.dismiss) private var dismiss
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
        VStack(alignment: .leading) {
          HStack {
            CategoryNameView(category: viewModel.product.category)
            ForEach(viewModel.product.subcategories, id: \.id) { subcategory in
              ChipView(title: subcategory.name, cornerRadius: 5)
            }
          }

          Text(viewModel.product.getDisplayName(.fullName))
            .font(.system(size: 18, weight: .bold, design: .default))
            .foregroundColor(.primary)

          Text(viewModel.product.getDisplayName(.brandOwner))
            .font(.system(size: 16, weight: .bold, design: .default))
            .foregroundColor(.secondary)
        }
        .onTapGesture {
          self.focusedField = nil
        }

        if viewModel.image != nil || viewModel.editCheckIn?.imageUrl != nil {
          HStack {
            Spacer()
            if let image = viewModel.image {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150, alignment: .top)
                .shadow(radius: 4)
            } else if let imageUrl = viewModel.editCheckIn?.getImageUrl() {
              CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 150, alignment: .top)
                  .shadow(radius: 4)
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
            WrappingHStack(viewModel.pickedFlavors, id: \.self) {
              flavor in ChipView(title: flavor.name.capitalized).padding(3)
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
          Picker("Serving Style", selection: $viewModel.servingStyleName) {
            Text("Not Selected").tag(ServingStyle.Name.none)
            ForEach(viewModel.servingStyles.map(\.name)) { servingStyle in
              Text(servingStyle.rawValue.capitalized)
            }
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
          FriendSheetView(viewModel.client, taggedFriends: $viewModel.taggedFriends)
        case .flavors:
          FlavorSheetView(viewModel.client, pickedFlavors: $viewModel.pickedFlavors)
        case .location:
          LocationSearchView(viewModel.client, onSelect: {
            location in viewModel.setLocation(location)
          })
        case .manufacturer:
          CompanySheetView(viewModel.client, onSelect: { company, _ in
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
      leading: Button(action: {
        dismiss()
      }) {
        Text("Cancel").bold()
      },
      trailing: Button(action: {
        switch action {
        case .create:
          if let onCreation {
            viewModel.createCheckIn {
              newCheckIn in
              onCreation(newCheckIn)
            }
          }
        case .update:
          if let onUpdate {
            viewModel.updateCheckIn {
              updatedCheckIn in
              onUpdate(updatedCheckIn)
            }
          }
        }
        dismiss()

      }) {
        Text(action == Action.create ? "Check-in!" : "Update Check-in!")
          .bold()
      }
    )
    .task {
      viewModel.loadInitialData()
    }
  }
}

extension CheckInSheetView {
  enum Focusable {
    case review
  }

  enum Action {
    case create
    case update
  }

  enum Sheet: Identifiable {
    var id: Self { self }
    case manufacturer
    case friends
    case flavors
    case location
    case photoPicker
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CheckInSheetView")
    let client: Client
    @Published var product: Product.Joined
    @Published var editCheckIn: CheckIn?
    @Published var selectedItem: PhotosPickerItem?
    @Published var activeSheet: Sheet?
    @Published var showCamera = false
    @Published var review: String = ""
    @Published var rating: Double = 0
    @Published var manufacturer: Company?
    @Published var servingStyleName: ServingStyle.Name = .none {
      // TODO: Investigate if this can be avoided by passing ServingStyle directly to the picker
      didSet {
        servingStyle = servingStyles.first(where: { $0.name == servingStyleName })
      }
    }

    @Published var servingStyles = [ServingStyle]()
    @Published var servingStyle: ServingStyle?
    @Published var taggedFriends = [Profile]()
    @Published var pickedFlavors = [Flavor]()
    @Published var location: Location?
    @Published var image: UIImage?

    init(_ client: Client, product: Product.Joined, editCheckIn: CheckIn?) {
      self.client = client
      self.product = product

      if let editCheckIn {
        self.editCheckIn = editCheckIn
        review = editCheckIn.review.orEmpty
        rating = editCheckIn.rating ?? 0
        manufacturer = editCheckIn.variant?.manufacturer
        servingStyleName = editCheckIn.servingStyle?.name ?? ServingStyle.Name.none
        taggedFriends = editCheckIn.taggedProfiles
        pickedFlavors = editCheckIn.flavors
        location = editCheckIn.location
      }
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func setLocation(_ location: Location) {
      self.location = location
    }

    func setManufacturer(_ company: Company) {
      manufacturer = company
    }

    func setImageFromCamera(_ image: UIImage) {
      Task {
        self.image = image
        self.showCamera = false
      }
    }

    func setImageFromPicker(pickedImage: UIImage) {
      image = pickedImage
    }

    func updateCheckIn(_ onUpdate: @escaping (_ checkIn: CheckIn) -> Void) {
      if let editCheckIn {
        let updateCheckInParams = CheckIn.UpdateRequest(
          checkIn: editCheckIn,
          product: product,
          review: review,
          taggedFriends: taggedFriends,
          servingStyle: servingStyle,
          manufacturer: manufacturer,
          flavors: pickedFlavors,
          rating: rating,
          location: location
        )

        Task {
          switch await client.checkIn.update(updateCheckInParams: updateCheckInParams) {
          case let .success(updatedCheckIn):
            uploadImage(checkIn: updatedCheckIn)
            onUpdate(updatedCheckIn)
          case let .failure(error):
            logger.error("failed to update check-in '\(editCheckIn.id)': \(error.localizedDescription)")
          }
        }
      }
    }

    func createCheckIn(_ onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
      let newCheckParams = CheckIn.NewRequest(
        product: product,
        review: review,
        taggedFriends: taggedFriends,
        servingStyle: servingStyle,
        manufacturer: manufacturer,
        flavors: pickedFlavors,
        rating: rating,
        location: location
      )

      Task {
        switch await client.checkIn.create(newCheckInParams: newCheckParams) {
        case let .success(newCheckIn):
          uploadImage(checkIn: newCheckIn)
          onCreation(newCheckIn)
        case let .failure(error):
          logger.error("failed to create check-in: \(error.localizedDescription)")
        }
      }
    }

    func uploadImage(checkIn: CheckIn) {
      Task {
        if let data = image?.jpegData(compressionQuality: 0.1) {
          switch await client.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id) {
          case let .failure(error):
            logger.error("failed to uplaod image to check-in '\(checkIn.id)': \(error.localizedDescription)")
          default:
            break
          }
        }
      }
    }

    func loadInitialData() {
      Task {
        switch await client.category.getServingStylesByCategory(categoryId: product.category.id) {
        case let .success(categoryServingStyles):
          self.servingStyles = categoryServingStyles.servingStyles
        case let .failure(error):
          logger
            .error(
              "failed to load serving styles by category '\(self.product.category.id)': \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
