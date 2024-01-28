import Components
import EnvironmentModels
import Extensions
import LegacyUIKit
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
    @State private var purchaseLocation: Location?
    @State private var checkInAt: Date = .now
    @State private var isLegacyCheckIn: Bool
    @State private var blurHash: String?
    @State private var alertError: AlertError?
    @State private var image: UIImage?
    @State private var imageMetadata: ImageMetadata? {
        didSet {
            if let imageTakenAt = imageMetadata?.date {
                checkInAt = imageTakenAt
            }
            if let imageTakenLocation = imageMetadata?.location {
                Task {
                    await getLocationFromCoordinate(coordinate: imageTakenLocation)
                }
            }
        }
    }

    @State private var finalImage: UIImage?
    @State private var showImageCropper = false
    @State private var sheet: Sheet?
    @State private var images: [ImageEntity]?

    let onCreation: ((_ checkIn: CheckIn) async -> Void)?
    let onUpdate: ((_ checkIn: CheckIn) async -> Void)?
    let action: Action
    let product: Product.Joined
    let editCheckIn: CheckIn?

    var showImageSection: Bool {
        if let images {
            return !images.isEmpty
        }
        return finalImage != nil
    }

    init(product: Product.Joined, onCreation: @escaping (_ checkIn: CheckIn) async -> Void) {
        self.onCreation = onCreation
        self.product = product
        editCheckIn = nil
        onUpdate = nil
        action = .create
        _isLegacyCheckIn = State(initialValue: false)
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
    }

    var body: some View {
        Form {
            topSection
            reviewSection
            additionalInformationSection
            locationAndFriendsSection
        }
        .foregroundColor(.primary)
        .sheets(item: $sheet)
        .confirmationDialog("Pick a photo", isPresented: $showPhotoMenu) {
            Button("Camera", action: { showCamera.toggle() })
            Button(
                "Photo Gallery",
                action: { sheet = .legacyPhotoPicker(onSelection: { image, metadata in
                    DispatchQueue.main.async {
                        imageMetadata = metadata
                        self.image = image
                        showImageCropper = true
                    }
                })
                }
            )
        } message: {
            Text("Pick a photo")
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
            finalImage: $finalImage
        )
        .alertError($alertError)
        .toolbar {
            toolbarContent
        }
        .task(id: finalImage, priority: .background) {
            if let finalImage, let hash = finalImage.resize(to: 100)?.blurHash(numberOfComponents: (5, 5)) {
                blurHash = BlurHash(hash: hash, height: finalImage.size.height, width: finalImage.size.width).encoded
            }
        }
        .onAppear {
            servingStyles =
                appEnvironmentModel.categories.first(where: { $0.id == product.category.id })?
                    .servingStyles ?? []
        }
    }

    @MainActor
    @ViewBuilder private var topSection: some View {
        Section {
            ProductItemView(product: product)
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    focusedField = nil
                }

            if showImageSection {
                HStack {
                    Spacer()
                    if let image = finalImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150, alignment: .top)
                            .shadow(radius: 4)
                            .accessibilityLabel("Image of the check-in")
                            .contextMenu {
                                ProgressButton("Delete") {
                                    finalImage = nil
                                }
                            }
                    }

                    if let images {
                        ForEach(images) { image in
                            RemoteImage(url: image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 150, alignment: .top)
                                        .shadow(radius: 4)
                                        .accessibilityLabel("Image of the check-in")
                                }
                            }
                            .contextMenu {
                                ProgressButton("Delete") {
                                    await deleteImage(entity: image)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            RatingPickerView(rating: $rating, incrementType: .small)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    @ViewBuilder private var reviewSection: some View {
        Section("Review") {
            TextField("How was it?", text: $review, axis: .vertical)
                .focused($focusedField, equals: .review)
            RouterLink(
                sheet: .flavors(pickedFlavors: $pickedFlavors),
                label: {
                    if !pickedFlavors.isEmpty {
                        FlavorsView(flavors: pickedFlavors)
                    } else {
                        Text("Flavors")
                    }
                }
            )
            Button(
                "\(editCheckIn?.getImageUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) == nil && image == nil ? "Add" : "Change") Photo",
                systemImage: "photo", action: { showPhotoMenu.toggle() }
            )
        }
        .headerProminence(.increased)
    }

    @ViewBuilder private var additionalInformationSection: some View {
        Section("checkIn.section.additionalInformation.title") {
            if !servingStyles.isEmpty {
                Picker(selection: $servingStyle) {
                    Text("Not Selected").tag(ServingStyle?(nil))
                    ForEach(servingStyles) { servingStyle in
                        Text(servingStyle.label).tag(Optional(servingStyle))
                    }
                } label: {
                    Text("Serving Style")
                }
                .pickerStyle(.navigationLink)
            }

            RouterLink(
                "Manufactured by \(manufacturer?.name ?? "")",
                sheet: .companySearch(onSelect: { company in
                    manufacturer = company
                })
            )
        }
    }

    @ViewBuilder private var locationAndFriendsSection: some View {
        Section("Location & Friends") {
            LocationInputButton(category: .checkIn, title: "Check-in Location", selection: location) { location in
                self.location = location
            }

            LocationInputButton(
                category: .purchase, title: "Purchase Location",
                selection: purchaseLocation
            ) { location in
                purchaseLocation = location
            }

            if profileEnvironmentModel.hasPermission(.canSetCheckInDate) {
                RouterLink(
                    sheet: .checkInDatePicker(checkInAt: $checkInAt, isLegacyCheckIn: $isLegacyCheckIn)
                ) {
                    Text(
                        isLegacyCheckIn
                            ? "Legacy Check-in"
                            : "Checked-in \(checkInAt.customFormat(.relativeTime).lowercased())")
                }
            }

            RouterLink(
                sheet: .friends(taggedFriends: $taggedFriends),
                label: {
                    if taggedFriends.isEmpty {
                        Text("Tag friends")
                    } else {
                        WrappingHStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
                            ForEach(taggedFriends) { friend in
                                Avatar(profile: friend, size: 24)
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
                action == .create ? "Check-in!" : "Update Check-in!",
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
            checkInAt: isLegacyCheckIn ? nil : checkInAt
        )

        switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
        case let .success(updatedCheckIn):
            if let finalImage {
                imageUploadEnvironmentModel.uploadCheckInImage(checkIn: updatedCheckIn, image: finalImage, blurHash: blurHash)
            }
            await onUpdate(updatedCheckIn.copyWith(images: images))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to update check-in '\(editCheckIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getLocationFromCoordinate(coordinate: CLLocationCoordinate2D) async {
        let countryCode = try? await coordinate.getISOCountryCode()
        let country = appEnvironmentModel.countries.first(where: { $0.countryCode == countryCode })
        location = Location(coordinate: coordinate, countryCode: countryCode, country: country)
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
            checkInAt: isLegacyCheckIn ? nil : checkInAt
        )

        switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
        case let .success(newCheckIn):
            if let finalImage {
                imageUploadEnvironmentModel.uploadCheckInImage(checkIn: newCheckIn, image: finalImage, blurHash: blurHash)
            }
            await onCreation(newCheckIn)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create check-in. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteImage(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .checkInImages, entity: entity) {
        case .success:
            withAnimation {
                images?.remove(object: entity)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
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
    let category: Location.RecentLocation
    let title: String
    let selection: Location?
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        RouterLink(
            sheet: .locationSearch(category: category, title: title, onSelect: onSelect),
            label: {
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
            }
        )
    }
}
