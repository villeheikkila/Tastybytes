import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct CheckInSheet: View {
    private let logger = Logger(category: "CheckInSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Focusable?
    @State private var primaryActionTask: Task<Void, Never>?
    @State private var servingStyles = [ServingStyle]()
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
    @State private var newImages = [UIImage]()
    @State private var images: [ImageEntity]

    let action: Action
    let product: Product.Joined

    init(action: Action) {
        self.action = action
        switch action {
        case let .create(product: product, _):
            self.product = product
            _isLegacyCheckIn = State(initialValue: false)
            _isNostalgic = State(initialValue: false)
            _images = State(initialValue: [])
        case let .update(checkIn, _):
            product = checkIn.product
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
    }

    var body: some View {
        Form {
            Group {
                ProductItemView(product: product)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        focusedField = nil
                    }
                CheckInImageManagementView(newImages: $newImages, images: $images, checkInAt: $checkInAt, locationFromImage: $locationFromImage)
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
            Button(
                action: { router.openSheet(.flavors(pickedFlavors: $pickedFlavors)) },
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
        .customListRowBackground()
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

            Button(
                "checkIn.manufacturedBy.label \(manufacturer?.name ?? "")",
                action: { router.openSheet(.companySearch(onSelect: { company in
                    manufacturer = company
                }))
                }
            )
        }
        .customListRowBackground()
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
                Button(action: {
                    router.openSheet(.checkInDatePicker(checkInAt: $checkInAt, isLegacyCheckIn: $isLegacyCheckIn, isNostalgic: $isNostalgic))
                }) {
                    Text(
                        isLegacyCheckIn
                            ? "checkIn.date.legacyCheckIn"
                            : "checkIn.date.checkInAt \(checkInAt.formatted(.customRelativetime).lowercased())")
                }
            }

            Button(
                action: { router.openSheet(.friends(taggedFriends: $taggedFriends)) },
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
        .customListRowBackground()
    }

    var primaryActionLabel: LocalizedStringKey {
        switch action {
        case .create:
            "checkIn.create.label"
        case .update:
            "checkIn.update.label"
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .primaryAction) {
            Button(
                primaryActionLabel,
                action: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }
            )
            .foregroundColor(.primary)
            .bold()
            .disabled(primaryActionTask != nil)
        }
    }

    func primaryAction() async {
        guard primaryActionTask != nil else { return }
        defer { primaryActionTask = nil }
        switch action {
        case let .create(product, onCreation):
            switch await repository.checkIn.create(newCheckInParams: .init(
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
            )) {
            case let .success(newCheckIn):
                imageUploadEnvironmentModel.uploadCheckInImage(checkIn: newCheckIn, images: newImages)
                if let onCreation {
                    await onCreation(newCheckIn)
                }
                feedbackEnvironmentModel.trigger(.notification(.success))
                dismiss()
            case let .failure(error):
                guard !error.isCancelled else { return }
                router.openAlert(.init(title: "checkIn.errors.failedToCreateCheckIn.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }))
                logger.error("Failed to create check-in. Error: \(error) (\(#file):\(#line))")
                return
            }
        case let .update(checkIn, onUpdate):
            switch await repository.checkIn.update(updateCheckInParams: .init(
                checkIn: checkIn,
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
            )) {
            case let .success(updatedCheckIn):
                imageUploadEnvironmentModel.uploadCheckInImage(checkIn: updatedCheckIn, images: newImages)
                if let onUpdate {
                    await onUpdate(updatedCheckIn.copyWith(images: images))
                }
                feedbackEnvironmentModel.trigger(.notification(.success))
                dismiss()
            case let .failure(error):
                guard !error.isCancelled else { return }
                router.openAlert(.init(title: "checkIn.errors.failedToUpdateCheckIn.title", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                }))
                logger.error("Failed to update check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}

extension CheckInSheet {
    enum Focusable {
        case review
    }

    enum Action: Hashable {
        case create(product: Product.Joined, onCreation: ((_ checkIn: CheckIn) async -> Void)?)
        case update(checkIn: CheckIn, onUpdate: ((_ checkIn: CheckIn) async -> Void)?)

        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case let (.create(lhsProduct, _), .create(rhsProduct, _)):
                lhsProduct == rhsProduct
            case let (.update(lhsCheckIn, _), .update(rhsCheckIn, _)):
                lhsCheckIn == rhsCheckIn
            default:
                false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case let .create(product, _):
                hasher.combine("create")
                hasher.combine(product)
            case let .update(checkIn, _):
                hasher.combine("update")
                hasher.combine(checkIn)
            }
        }
    }
}
