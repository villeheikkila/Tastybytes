import Components

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
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @Environment(CheckInUploadModel.self) private var checkInUploadModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Focusable?
    @State private var primaryActionTask: Task<Void, Never>?
    @State private var servingStyles = [ServingStyle.Saved]()
    // check-in properties
    @State private var pickedFlavors = [Flavor.Saved]()
    @State private var review: String = ""
    @State private var rating: Double = 0
    @State private var manufacturer: Company.Saved?
    @State private var servingStyle: ServingStyle.Saved?
    @State private var taggedFriends = [Profile.Saved]()
    @State private var location: Location.Saved?
    @State private var locationFromImage: Location.Saved?
    @State private var purchaseLocation: Location.Saved?
    @State private var checkInAt: Date = .now
    @State private var isLegacyCheckIn: Bool
    @State private var isNostalgic: Bool
    @State private var newImages = [UIImage]()
    @State private var images: [ImageEntity.Saved]
    @State private var product: Product.Joined?

    let action: Action

    init(action: Action) {
        self.action = action
        switch action {
        case let .create(product: product, _):
            _product = State(initialValue: product)
            _isLegacyCheckIn = State(initialValue: false)
            _isNostalgic = State(initialValue: false)
            _images = State(initialValue: [])
        case let .update(checkIn, _):
            _product = State(initialValue: checkIn.product)
            _images = State(initialValue: checkIn.images)
            _review = State(wrappedValue: checkIn.review.orEmpty)
            _rating = State(wrappedValue: checkIn.rating ?? 0)
            _manufacturer = State(wrappedValue: checkIn.variant?.manufacturer)
            _servingStyle = State(wrappedValue: checkIn.servingStyle)
            _taggedFriends = State(wrappedValue: checkIn.taggedProfiles.map(\.profile))
            _pickedFlavors = State(wrappedValue: checkIn.flavors)
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
                if let currentProduct = product {
                    RouterLink(open: .sheet(.productPicker(product: $product))) {
                        ProductView(product: currentProduct)
                            .accessibilityAddTraits(.isButton)
                    }
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
            guard let product else { return }
            servingStyles = appModel.categories.first(where: { $0.id == product.category.id })?.servingStyles ?? []
        }
    }

    @ViewBuilder private var reviewSection: some View {
        Section("checkIn.review.title") {
            TextField("checkIn.review.label", text: $review, axis: .vertical)
                .focused($focusedField, equals: .review)
            RouterLink(open: .sheet(.flavorPicker(pickedFlavors: $pickedFlavors)),
                       label: {
                           if !pickedFlavors.isEmpty {
                               FlavorsView(flavors: pickedFlavors)
                           } else {
                               Text("flavors.label")
                           }
                       })
        }
        .headerProminence(.increased)
        .customListRowBackground()
    }

    @ViewBuilder private var additionalInformationSection: some View {
        Section("checkIn.section.additionalInformation.title") {
            if !servingStyles.isEmpty {
                Picker(selection: $servingStyle) {
                    Text("servingStyle.unselected").tag(ServingStyle.Saved?(nil))
                    ForEach(servingStyles) { servingStyle in
                        ServingStyleView(servingStyle: servingStyle)
                            .tag(Optional(servingStyle))
                    }
                } label: {
                    Text("servingStyle.title")
                }
                .pickerStyle(.navigationLink)
            }

            RouterLink(
                "checkIn.manufacturedBy.label \(manufacturer?.name ?? "")",
                open: .sheet(.companyPicker(onSelect: { company in
                    manufacturer = company
                }))
            )
        }
        .customListRowBackground()
    }

    @ViewBuilder private var locationAndFriendsSection: some View {
        Section("checkIn.section.locationsFriends.title") {
            LocationInputButtonView(category: .checkIn, title: "checkIn.location.add.label", selection: $location, initialLocation: $locationFromImage, onSelect: { location in
                self.location = location
            })

            LocationInputButtonView(
                category: .purchase, title: "checkIn.purchaseLocation.add.label",
                selection: $purchaseLocation,
                initialLocation: $locationFromImage,
                onSelect: { location in
                    purchaseLocation = location
                }
            )

            RouterLink(open: .sheet(.checkInDatePicker(checkInAt: $checkInAt, isLegacyCheckIn: $isLegacyCheckIn, isNostalgic: $isNostalgic))) {
                Text(
                    isLegacyCheckIn
                        ? "checkIn.date.legacyCheckIn"
                        : "checkIn.date.checkInAt \(checkInAt.formatted(.customRelativetime).lowercased())")
            }

            RouterLink(open: .sheet(.friendPicker(taggedFriends: $taggedFriends))) {
                if taggedFriends.isEmpty {
                    Text("checkIn.friends.tag")
                } else {
                    WStack(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
                        ForEach(taggedFriends) { friend in
                            AvatarView(profile: friend)
                                .avatarSize(.large)
                        }
                    }
                }
            }
        }
        .customListRowBackground()
    }

    private var primaryActionLabel: LocalizedStringKey {
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

    private func primaryAction() async {
        guard primaryActionTask != nil else { return }
        defer { primaryActionTask = nil }
        switch action {
        case let .create(product, onCreation):
            do {
                let newCheckIn = try await repository.checkIn.create(newCheckInParams: .init(
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
                ))
                checkInUploadModel.uploadCheckInImage(checkIn: newCheckIn, images: newImages)
                if let onCreation {
                    await onCreation(newCheckIn)
                }
                feedbackModel.trigger(.notification(.success))
                dismiss()
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init(title: "checkIn.errors.failedToCreateCheckIn.title", retryLabel: "labels.retry", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                })))
                logger.error("Failed to create check-in. Error: \(error) (\(#file):\(#line))")
                return
            }
        case let .update(checkIn, onUpdate):
            do {
                guard let product else { return }
                let updatedCheckIn = try await repository.checkIn.update(updateCheckInParams: .init(
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
                ))
                checkInUploadModel.uploadCheckInImage(checkIn: updatedCheckIn, images: newImages)
                if let onUpdate {
                    await onUpdate(updatedCheckIn.copyWith(images: images))
                }
                feedbackModel.trigger(.notification(.success))
                dismiss()
            } catch {
                guard !error.isCancelled else { return }
                router.open(.alert(.init(title: "checkIn.errors.failedToUpdateCheckIn.title", retry: {
                    primaryActionTask = Task {
                        await primaryAction()
                    }
                })))
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
        case create(product: Product.Joined, onCreation: ((_ checkIn: CheckIn.Joined) async -> Void)?)
        case update(checkIn: CheckIn.Joined, onUpdate: ((_ checkIn: CheckIn.Joined) async -> Void)?)

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
