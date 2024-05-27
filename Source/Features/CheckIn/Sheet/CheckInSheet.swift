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
    @State private var servingStyles = [ServingStyle]()
    @State private var alertError: AlertError?
    @State private var sheet: Sheet?
    // check-in properties
    @State private var pickedFlavors = [Flavor]()
    @State private var review: String = ""
    @State private var rating: Double = 0
    @State private var manufacturer: Company?
    @State private var servingStyle: ServingStyle?
    @State private var taggedFriends = [Profile]()
    @State private var location: Location?
    @State private var locationFromImage: Location?
    @State private var purchaseLocation: Location?
    @State private var checkInAt: Date = .now
    @State private var isLegacyCheckIn: Bool
    @State private var isNostalgic: Bool
    @State private var image: UIImage?
    @State private var newImages = [UIImage]()
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
                CheckInImageManagementView(newImages: $newImages, images: $images,
                                           image: $image, checkInAt: $checkInAt, locationFromImage: $locationFromImage)
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
        .toolbarBackground(.hidden, for: .navigationBar)
        .foregroundColor(.primary)
        .sheets(item: $sheet)
        .alertError($alertError)
        .toolbar {
            toolbarContent
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
