import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct CheckInSheet: View {
    private let logger = Logger(category: "CheckInSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
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
    @State private var locationFromImage: Location?
    @State private var purchaseLocation: Location?
    @State private var checkInAt: Date = .now
    @State private var isLegacyCheckIn: Bool
    @State private var isNostalgic: Bool
    @State private var alertError: AlertError?
    @State private var image: UIImage?
    @State private var showPhotoPicker = false
    @State private var photoSelection: PhotosPickerItem?

    @State private var newImages = [UIImage]()
    @State private var showImageCropper = false
    @State private var sheet: Sheet?
    @State private var images: [ImageEntity]

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
        _isNostalgic = State(initialValue: false)
        _images = State(initialValue: [])
    }

    init(
        checkIn: CheckIn,
        onUpdate: @escaping (_ checkIn: CheckIn) async -> Void
    ) {
        product = checkIn.product
        onCreation = nil
        self.onUpdate = onUpdate
        action = .update
        editCheckIn = checkIn
        _images = State(initialValue: checkIn.images)
        _review = State(wrappedValue: checkIn.review.orEmpty)
        _rating = State(wrappedValue: checkIn.rating ?? 0)
        _manufacturer = State(wrappedValue: checkIn.variant?.manufacturer)
        _servingStyle = State(wrappedValue: checkIn.servingStyle)
        _taggedFriends = State(wrappedValue: checkIn.taggedProfiles.map(\.profile))
        _pickedFlavors = State(wrappedValue: checkIn.flavors.map(\.flavor))
        _location = State(wrappedValue: checkIn.location)
        _purchaseLocation = State(wrappedValue: checkIn.purchaseLocation)
        _checkInAt = State(wrappedValue: checkIn.checkInAt ?? Date.now)
        _isLegacyCheckIn = State(initialValue: checkIn.checkInAt == nil)
        _isNostalgic = State(initialValue: checkIn.isNostalgic)
    }

    var body: some View {
        Form {
            Group {
                ProductItemView(product: product)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        focusedField = nil
                    }
                CheckInImageManagementView(newImages: $newImages, images: $images, showPhotoMenu: $showPhotoMenu, deleteImage: deleteImage)
                    .listRowInsets(.init())
                RatingPickerView(rating: $rating)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            reviewSection
            additionalInformationSection
            locationAndFriendsSection
        }
        .scrollContentBackground(.hidden)
        .foregroundColor(.primary)
        .sheets(item: $sheet)
        .confirmationDialog("checkIn.photo.title", isPresented: $showPhotoMenu) {
            Button("checkIn.photo.picker.camera", action: { showCamera.toggle() })
            Button(
                "checkIn.photo.picker.photoGallery",
                action: {
                    showPhotoPicker = true
                }
            )
        } message: {
            Text("checkIn.photo.picker.title")
        }
        .fullScreenCamera(
            isPresented: $showCamera,
            selectedImage: .init(
                get: {
                    nil
                },
                set: { image in
                    guard let image else { return }
                    self.image = image
                    showImageCropper = true
                }
            )
        )
        .fullScreenImageCrop(
            isPresented: $showImageCropper,
            image: image,
            onSubmit: { image in
                if let image {
                    newImages.append(image)
                }
            }
        )
        .alertError($alertError)
        .toolbar {
            toolbarContent
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoSelection, matching: .images, photoLibrary: .shared())
        .onChange(of: photoSelection) {
            Task {
                guard let photoSelection, let data = try? await photoSelection.loadTransferable(type: Data.self) else { return }
                if let imageTakenAt = photoSelection.imageMetadata.date {
                    checkInAt = imageTakenAt
                }
                if let imageTakenLocation = photoSelection.imageMetadata.location {
                    await getLocationFromCoordinate(coordinate: imageTakenLocation)
                }
                image = UIImage(data: data)
                showImageCropper = true
            }
        }
        .onAppear {
            servingStyles =
                appEnvironmentModel.categories.first(where: { $0.id == product.category.id })?
                    .servingStyles ?? []
        }
    }

    @ViewBuilder private var reviewSection: some View {
        Section("checkIn.review.title") {
            TextField("checkIn.review.label", text: $review, axis: .vertical)
                .focused($focusedField, equals: .review)
            RouterLink(
                sheet: .flavors(pickedFlavors: $pickedFlavors),
                label: {
                    if !pickedFlavors.isEmpty {
                        FlavorsView(flavors: pickedFlavors)
                    } else {
                        Text("flavors.label")
                    }
                }
            )
        }
        .headerProminence(.increased)
    }

    @ViewBuilder private var additionalInformationSection: some View {
        Section("checkIn.section.additionalInformation.title") {
            if !servingStyles.isEmpty {
                Picker(selection: $servingStyle) {
                    Text("servingStyle.unselected").tag(ServingStyle?(nil))
                    ForEach(servingStyles) { servingStyle in
                        Text(servingStyle.label).tag(Optional(servingStyle))
                    }
                } label: {
                    Text("servingStyle.title")
                }
                .pickerStyle(.navigationLink)
            }

            RouterLink(
                "checkIn.manufacturedBy.label \(manufacturer?.name ?? "")",
                sheet: .companySearch(onSelect: { company in
                    manufacturer = company
                })
            )
        }
    }

    @ViewBuilder private var locationAndFriendsSection: some View {
        Section("checkIn.section.locationsFriends.title") {
            LocationInputButton(category: .checkIn, title: "checkIn.location.add.label", selection: $location, initialLocation: $locationFromImage, onSelect: { location in
                self.location = location
            })

            LocationInputButton(
                category: .purchase, title: "checkIn.purchaseLocation.add.label",
                selection: $purchaseLocation,
                initialLocation: $locationFromImage,
                onSelect: { location in
                    purchaseLocation = location
                }
            )

            if profileEnvironmentModel.hasPermission(.canSetCheckInDate) {
                RouterLink(
                    sheet: .checkInDatePicker(checkInAt: $checkInAt, isLegacyCheckIn: $isLegacyCheckIn, isNostalgic: $isNostalgic)
                ) {
                    Text(
                        isLegacyCheckIn
                            ? "checkIn.date.legacyCheckIn"
                            : "checkIn.date.checkInAt \(checkInAt.formatted(.customRelativetime).lowercased())")
                }
            }

            RouterLink(
                sheet: .friends(taggedFriends: $taggedFriends),
                label: {
                    if taggedFriends.isEmpty {
                        Text("checkIn.friends.tag")
                    } else {
                        WrappingHStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
                            ForEach(taggedFriends) { friend in
                                Avatar(profile: friend)
                                    .avatarSize(.medium)
                            }
                        }
                    }
                }
            )
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .primaryAction) {
            ProgressButton(
                action == .create ? "checkIn.create.label" : "checkIn.update.label",
                action: {
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
                    feedbackEnvironmentModel.trigger(.notification(.success))
                    dismiss()
                }
            )
            .foregroundColor(.primary)
            .bold()
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
            checkInAt: isLegacyCheckIn ? nil : checkInAt,
            isNostalgic: isNostalgic
        )

        switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
        case let .success(updatedCheckIn):
            imageUploadEnvironmentModel.uploadCheckInImage(checkIn: updatedCheckIn, images: newImages)
            await onUpdate(updatedCheckIn.copyWith(images: images))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update check-in '\(editCheckIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D) async {
        let countryCode = try? await coordinate.getISOCountryCode()
        let country = appEnvironmentModel.countries.first(where: { $0.countryCode == countryCode })
        locationFromImage = Location(coordinate: coordinate, countryCode: countryCode, country: country)
    }

    func storeLocation(_ location: Location) async {
        switch await repository.location.insert(location: location) {
        case let .success(savedLocation):
            logger.info("Succesfully created a location \(savedLocation.name) from an image")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Saving location \(location.name) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteImage(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .checkInImages, entity: entity) {
        case .success:
            withAnimation {
                images.remove(object: entity)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
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
            checkInAt: isLegacyCheckIn ? nil : checkInAt,
            isNostalgic: isNostalgic
        )

        switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
        case let .success(newCheckIn):
            imageUploadEnvironmentModel.uploadCheckInImage(checkIn: newCheckIn, images: newImages)
            await onCreation(newCheckIn)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create check-in. Error: \(error) (\(#file):\(#line))")
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

@MainActor struct CheckInImageManagementView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Binding var newImages: [UIImage]
    @Binding var images: [ImageEntity]
    @Binding var showPhotoMenu: Bool
    let deleteImage: (_ image: ImageEntity) async -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center) {
                ForEach(newImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 8))
                        .frame(height: 150)
                        .shadow(radius: 1)
                        .accessibilityLabel("checkIn.image.label")
                        .overlayDeleteButton(action: {
                            if let index = newImages.firstIndex(of: image) {
                                newImages.remove(at: index)
                            }

                        })
                }

                ForEach(images) { image in
                    RemoteImage(url: image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 8))
                                .frame(height: 150)
                                .shadow(radius: 1)
                                .accessibilityLabel("checkIn.image.label")
                        }
                    }
                    .overlayDeleteButton(action: {
                        await deleteImage(image)
                    })
                }
                VStack(alignment: .center) {
                    Spacer()
                    Label("checkIn.image.add", systemImage: "camera")
                        .font(.system(size: 24))
                    Spacer()
                }
                .labelStyle(.iconOnly)
                .frame(width: 110, height: 150)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                .shadow(radius: 1)
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    showPhotoMenu.toggle()
                }
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 16)
    }
}

@MainActor
struct LocationInputButton: View {
    let category: Location.RecentLocation
    let title: LocalizedStringKey
    @Binding var selection: Location?
    @Binding var initialLocation: Location?
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        RouterLink(
            sheet: .locationSearch(category: category, title: title, initialLocation: $initialLocation, onSelect: onSelect),
            label: {
                HStack {
                    if let location = selection, let coordinate = selection?.location?.coordinate {
                        MapThumbnail(location: location, coordinate: coordinate, distance: nil)
                    }
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
                    Spacer()
                    if selection != nil {
                        Button("checkIn.location.reset", systemImage: "xmark") {
                            selection = nil
                        }.labelStyle(.iconOnly)
                    }
                }
            }
        )
    }
}

struct OverlayDeleteButtonModifier: ViewModifier {
    @State private var submitting = false
    var action: () async -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Label("labels.delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .imageScale(.small)
                    .tint(.red)
                    .padding(3)
                    .foregroundColor(.red)
                    .background(.ultraThinMaterial, in: .circle)
            }
            .padding(4)
            .onTapGesture {
                guard submitting == false else { return }
                Task {
                    submitting = true
                    await action()
                    submitting = false
                }
            }
    }
}

extension View {
    func overlayDeleteButton(action: @escaping () async -> Void) -> some View {
        modifier(OverlayDeleteButtonModifier(action: action))
    }
}
