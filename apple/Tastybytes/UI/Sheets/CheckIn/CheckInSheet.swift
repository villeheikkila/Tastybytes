import CachedAsyncImage
import PhotosUI
import SwiftUI
import WrappingHStack
import os

struct CheckInSheet: View {
  private let logger = Logger(category: "CheckInSheet")
  @Environment(Repository.self) private var repository
  @Environment(FeedbackManager.self) private var feedbackManager
  @Environment(ProfileManager.self) private var profileManager
  @Environment(AppDataManager.self) private var appDataManager
  @Environment(ImageUploadManager.self) private var imageUploadManager
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
  @State private var isLegacyCheckIn: Bool
  @State private var blurHash: String?
  @State private var image: UIImage? {
    didSet {
      Task {
        if let image, let hash = image.resize(to: 100)?
          .blurHash(numberOfComponents: (5, 5))
        {
          blurHash = CheckIn.BlurHash(hash: hash, height: image.size.height, width: image.size.width).encoded
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
    _isLegacyCheckIn = State(initialValue: false)
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
    _isLegacyCheckIn = State(initialValue: checkIn.checkInAt == nil)
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
        RatingPickerView(rating: $rating, incrementType: .small)
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)

      Section("Review") {
        TextField("How was it?", text: $review, axis: .vertical)
          .focused($focusedField, equals: .review)
        RouterLink(sheet: .flavors(pickedFlavors: $pickedFlavors), label: {
          if !pickedFlavors.isEmpty {
            WrappingHStack(pickedFlavors, spacing: .constant(4)) { flavor in
              ChipView(title: flavor.label)
            }
          } else {
            Text("Flavors")
          }
        })
        Button("\(editCheckIn?.imageUrl == nil && image == nil ? "Add" : "Change") Photo",
               systemSymbol: .photo, action: { showPhotoMenu.toggle() })
      }
      .headerProminence(.increased)

      Section("Additional Information") {
        if !servingStyles.isEmpty {
          Picker(selection: $servingStyle) {
            Text("Not Selected").tag(ServingStyle?(nil))
            ForEach(servingStyles) { servingStyle in
              Text(servingStyle.label).tag(Optional(servingStyle))
            }
          } label: {
            Text("Serving Style")
          }
        }

        RouterLink("Manufactured by \(manufacturer?.name ?? "")", sheet: .companySearch(onSelect: { company in
          manufacturer = company
        }))
      }

      Section("Location & Friends") {
        LocationInputButton(title: "Check-in Location", selection: location) { location in
          self.location = location
        }

        LocationInputButton(title: "Purchase Location", selection: purchaseLocation) { location in
          purchaseLocation = location
        }

        if profileManager.hasPermission(.canSetCheckInDate) {
          RouterLink(sheet: .checkInDatePicker(checkInAt: $checkInAt, isLegacyCheckIn: $isLegacyCheckIn)) {
            Text(isLegacyCheckIn ? "Legacy Check-in" : "Checked-in \(checkInAt.customFormat(.relativeTime).lowercased())")
          }
        }

        RouterLink(sheet: .friends(taggedFriends: $taggedFriends), label: {
          if taggedFriends.isEmpty {
            Text("Tag friends")
          } else {
            WrappingHStack(taggedFriends) { friend in
              AvatarView(avatarUrl: friend.avatarUrl, size: 24, id: friend.id)
            }
          }
        })
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
      checkInAt: isLegacyCheckIn ? nil : checkInAt
    )

    switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
    case let .success(updatedCheckIn):
      if let image {
        imageUploadManager.uploadCheckInImage(checkIn: updatedCheckIn, image: image)
      }
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
      checkInAt: isLegacyCheckIn ? nil : checkInAt
    )

    switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
    case let .success(newCheckIn):
      if let image {
        imageUploadManager.uploadCheckInImage(checkIn: newCheckIn, image: image)
      }
      await onCreation(newCheckIn)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create check-in: \(error.localizedDescription)")
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

struct LocationInputButton: View {
  let title: String
  let selection: Location?
  let onSelect: (_ location: Location) -> Void

  var body: some View {
    RouterLink(sheet: .locationSearch(title: title, onSelect: onSelect), label: {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)

        if let selection {
          Text(selection.name)
            .foregroundColor(.secondary)

          if let locationTitle = selection.title {
            Text(locationTitle)
              .foregroundColor(.secondary)
              .font(.caption)
          }
        }
      }
    })
  }
}
