import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack

struct CheckInSheet: View {
  private let logger = getLogger(category: "CheckInSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focusedField: Focusable?
  @State private var showPhotoMenu = false
  @State private var pickedFlavors = [Flavor]()
  @State private var showCamera = false
  @State private var review: String = ""
  @State private var rating: Double = 0
  @State private var manufacturer: Company?
  @State private var servingStyles = [ServingStyle]()
  @State private var servingStyle: ServingStyle?
  @State private var taggedFriends = [Profile]()
  @State private var location: Location?
  @State private var purchaseLocation: Location?
  @State private var checkInAt: Date = .now
  @State private var blurHash: String?
  @State private var image: UIImage? {
    didSet {
      Task {
        if let image, let hash = image.resize(to: 100)?
          .blurHash(numberOfComponents: (5, 5))
        {
          blurHash = "\(image.size.width):\(image.size.height):::\(hash)"
        }
      }
    }
  }

  let onCreation: ((_ checkIn: CheckIn) async -> Void)?
  let onUpdate: ((_ checkIn: CheckIn) async -> Void)?
  let action: Action
  let product: Product.Joined
  let editCheckIn: CheckIn?

  init(product: Product.Joined, onCreation: @escaping (_ checkIn: CheckIn) async -> Void) {
    self.onCreation = onCreation
    self.product = product
    editCheckIn = nil
    onUpdate = nil
    action = .create
  }

  init(checkIn: CheckIn,
       onUpdate: @escaping (_ checkIn: CheckIn) async -> Void)
  {
    product = checkIn.product
    onCreation = nil
    self.onUpdate = onUpdate
    action = .update
    editCheckIn = checkIn
    _review = State(wrappedValue: checkIn.review.orEmpty)
    _rating = State(wrappedValue: checkIn.rating ?? 0)
    _manufacturer = State(wrappedValue: checkIn.variant?.manufacturer)
    _servingStyle = State(wrappedValue: checkIn.servingStyle)
    _taggedFriends = State(wrappedValue: checkIn.taggedProfiles)
    _pickedFlavors = State(wrappedValue: checkIn.flavors)
    _location = State(wrappedValue: checkIn.location)
    _purchaseLocation = State(wrappedValue: checkIn.purchaseLocation)
    _checkInAt = State(wrappedValue: checkIn.checkInAt ?? Date.now)
  }

  var body: some View {
    Form {
      Section {
        ProductItemView(product: product)
          .accessibilityAddTraits(.isButton)
          .onTapGesture {
            focusedField = nil
          }

        if image != nil || editCheckIn?.imageFile != nil {
          HStack {
            Spacer()
            if let image {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150, alignment: .top)
                .shadow(radius: 4)
                .accessibilityLabel("Image of the check-in")
            } else if let imageUrl = editCheckIn?.imageUrl {
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

      Section("Review") {
        TextField("How was it?", text: $review, axis: .vertical)
          .focused($focusedField, equals: .review)
        RatingPickerView(rating: $rating)
        RouterLink(sheet: .flavors(pickedFlavors: $pickedFlavors), label: {
          if !pickedFlavors.isEmpty {
            WrappingHStack(pickedFlavors, spacing: .constant(4)) { flavor in
              ChipView(title: flavor.label)
            }
          } else {
            Text("Flavors")
              .fontWeight(.medium)
          }
        })
        Button("\(editCheckIn?.imageUrl == nil && image == nil ? "Add" : "Change") Photo",
               systemImage: "photo", action: { showPhotoMenu.toggle() }).fontWeight(.medium)
      }.headerProminence(.increased)

      Section("Additional Information") {
        if !servingStyles.isEmpty {
          Picker(selection: $servingStyle) {
            Text("Not Selected").tag(ServingStyle?(nil))
            ForEach(servingStyles) { servingStyle in
              Text(servingStyle.label).tag(Optional(servingStyle))
            }
          } label: {
            Text("Serving Style")
              .fontWeight(.medium)
          }
        }

        RouterLink(manufacturer?.name ?? "Manufactured By", sheet: .companySearch(onSelect: { company in
          manufacturer = company
        }))
        .fontWeight(.medium)
      }

      Section {
        RouterLink(sheet: .friends(taggedFriends: $taggedFriends), label: {
          if taggedFriends.isEmpty {
            Text("Tag friends")
              .fontWeight(.medium)
          } else {
            WrappingHStack(taggedFriends) { friend in
              AvatarView(avatarUrl: friend.avatarUrl, size: 24, id: friend.id)
            }
          }
        })
      }

      Section("Location") {
        RouterLink(sheet: .locationSearch(onSelect: { location in
          self.location = location
        }), label: {
          HStack {
            if let location {
              Text(location.name)
              if let title = location.title {
                Text(title)
                  .foregroundColor(.secondary)
              }
            } else {
              Text("Location")
                .fontWeight(.medium)
            }
            Spacer()
          }
        })
      }

      Section("Purchased from") {
        RouterLink(sheet: .locationSearch(onSelect: { location in
          purchaseLocation = location
        }), label: {
          HStack {
            if let location = purchaseLocation {
              Text(location.name)
              if let title = location.title {
                Text(title)
                  .foregroundColor(.secondary)
              }
            } else {
              Text("Purchase Location")
                .fontWeight(.medium)
            }
            Spacer()
          }
        })
      }

      if profileManager.hasPermission(.canSetCheckInDate) {
        DatePicker(selection: $checkInAt, in: ...Date.now) {
          Text("Check-in Date")
        }
      }
    }
    .confirmationDialog("Pick a photo", isPresented: $showPhotoMenu) {
      Button("Camera", action: { showCamera.toggle() })
      RouterLink("Photo Gallery", sheet: .legacyPhotoPicker(onSelection: { image in
        setImageFromPicker(pickedImage: image)
      }))
    } message: {
      Text("Pick a photo")
    }
    .fullScreenCover(isPresented: $showCamera, content: {
      CameraView(onClose: {
        showCamera = false
      }, onCapture: { image in Task {
        await setImageFromCamera(image)
      }
      })
    })
    .navigationBarItems(
      leading: Button("Cancel", role: .cancel, action: { dismiss() }),
      trailing: ProgressButton(action == .create ? "Check-in!" : "Update Check-in!", action: {
        switch action {
        case .create:
          if let onCreation {
            await createCheckIn { newCheckIn in
              await onCreation(newCheckIn)
            }
          }
        case .update:
          if let onUpdate {
            await updateCheckIn { updatedCheckIn in
              await onUpdate(updatedCheckIn)
            }
          }
        }
        feedbackManager.trigger(.notification(.success))
        dismiss()
      }).bold()
    )
    .onAppear {
      servingStyles = appDataManager.categories.first(where: { $0.id == product.category.id })?
        .servingStyles ?? []
    }
  }

  func setImageFromCamera(_ image: UIImage) async {
    Task {
      self.image = image
      showCamera = false
    }
  }

  func setImageFromPicker(pickedImage: UIImage) {
    Task {
      image = pickedImage
    }
  }

  func updateCheckIn(_ onUpdate: @escaping (_ checkIn: CheckIn) async -> Void) async {
    guard let editCheckIn else { return }
    let updateCheckInParams = CheckIn.UpdateRequest(
      checkIn: editCheckIn,
      product: product,
      review: review,
      taggedFriends: taggedFriends,
      servingStyle: servingStyle,
      manufacturer: manufacturer,
      flavors: pickedFlavors,
      rating: rating,
      location: location,
      purchaseLocation: purchaseLocation,
      blurHash: blurHash,
      checkInAt: checkInAt
    )

    switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
    case let .success(updatedCheckIn):
      await uploadImage(checkIn: updatedCheckIn)
      await onUpdate(updatedCheckIn)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update check-in '\(editCheckIn.id)': \(error.localizedDescription)")
    }
  }

  func createCheckIn(_ onCreation: @escaping (_ checkIn: CheckIn) async -> Void) async {
    let newCheckParams = CheckIn.NewRequest(
      product: product,
      review: review,
      taggedFriends: taggedFriends,
      servingStyle: servingStyle,
      manufacturer: manufacturer,
      flavors: pickedFlavors,
      rating: rating,
      location: location,
      purchaseLocation: purchaseLocation,
      blurHash: blurHash,
      checkInAt: checkInAt
    )

    switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
    case let .success(newCheckIn):
      await uploadImage(checkIn: newCheckIn)
      await onCreation(newCheckIn)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create check-in: \(error.localizedDescription)")
    }
  }

  func uploadImage(checkIn: CheckIn) async {
    guard let data = image?.jpegData(compressionQuality: 0.1) else { return }
    switch await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id) {
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to uplaod image to check-in '\(checkIn.id)': \(error.localizedDescription)")
    default:
      break
    }
  }
}

extension CheckInSheet {
  enum Focusable {
    case review
  }

  enum Action {
    case create
    case update
  }
}
