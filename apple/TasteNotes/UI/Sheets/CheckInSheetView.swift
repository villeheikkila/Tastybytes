import PhotosUI
import SwiftUI
import WrappingHStack

struct CheckInSheetView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    
    let product: ProductJoined
    let onCreation: ((_ checkIn: CheckIn) -> Void)?
    let onUpdate: ((_ checkIn: CheckIn) -> Void)?
    let existingCheckIn: CheckIn?
    let action: Action

    init(product: ProductJoined, onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
        self.product = product
        existingCheckIn = nil
        self.onCreation = onCreation
        onUpdate = nil
        action = Action.create
    }

    init(checkIn: CheckIn,
         onUpdate: @escaping (_ checkIn: CheckIn) -> Void) {
        product = checkIn.product
        existingCheckIn = checkIn
        onCreation = nil
        self.onUpdate = onUpdate
        action = Action.update
    }

    var body: some View {
        NavigationStack {
            VStack {
                ProductCardView(product: product)
                photoPicker
                Form {
                    Section {
                        TextField("How was it?", text: $viewModel.review, axis: .vertical)
                        RatingPickerView(rating: $viewModel.rating)
                        Button(action: {
                            viewModel.activateSheet(.flavors)
                        }) {
                            if viewModel.pickedFlavors.count != 0 {
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
                        if viewModel.servingStyles.count > 0 {
                            Picker("Serving Style", selection: $viewModel.servingStyle) {
                                Text("Not Selected").tag(ServingStyleName.none)
                                ForEach(viewModel.servingStyles.map { $0.name }) { servingStyle in
                                    Text(servingStyle.rawValue.capitalized)
                                }
                            }
                        }

                        Button(action: {
                            viewModel.activateSheet(.manufacturer)
                        }) {
                            Text(viewModel.manufacturer?.name ?? "Manufactured by")
                        }
                    }

                    Section {
                        Button(action: {
                            viewModel.activateSheet(.friends)
                        }) {
                            if viewModel.taggedFriends.count == 0 {
                                Text("Tag friends")
                            } else {
                                WrappingHStack(viewModel.taggedFriends, id: \.self) {
                                    friend in
                                    AvatarView(avatarUrl: friend.getAvatarURL(), size: 24, id: friend.id)
                                }
                            }
                        }
                    }

                    Button(action: {
                        viewModel.activateSheet(.location)
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
                .sheet(item: $viewModel.activeSheet) { sheet in
                    switch sheet {
                    case .friends:
                        FriendSheetView(taggedFriends: $viewModel.taggedFriends)
                    case .flavors:
                        FlavorSheetView(initialFlavors: viewModel.pickedFlavors, onComplete: {
                            pickedFlavors in viewModel.setFlavors(pickedFlavors)
                        })
                    case .location:
                        LocationSearchView(onSelect: {
                            location in viewModel.setLocation(location)
                        })
                    case .manufacturer:
                        CompanySheetView(onSelect: { company, _ in
                            viewModel.setManufacturer(company)
                        })
                    }
                }
                .navigationBarItems(
                    leading: Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .bold()
                    },
                    trailing: Button(action: {
                        switch action {
                        case .create:
                            if let onCreation = onCreation {
                                viewModel.createCheckIn(product, {
                                    newCheckIn in
                                    onCreation(newCheckIn)
                                })
                            }
                        case .update:
                            if let existingCheckIn = existingCheckIn, let onUpdate = onUpdate {
                                viewModel.updateCheckIn(existingCheckIn, {
                                    newCheckIn in
                                    onUpdate(newCheckIn)
                                })
                            }
                        }
                        dismiss()

                    }) {
                        Text(action == Action.create ? "Check-in!" : "Update Check-in!")
                            .bold()
                    })
                .task {
                    viewModel.loadInitialData(product: product)
                    if let existingCheckIn = existingCheckIn {
                        viewModel.loadFromCheckIn(checkIn: existingCheckIn)
                    }
                }
            }
        }
    }

    var photoPicker: some View {
        PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150, alignment: .top)
                    .shadow(radius: 4)
            } else {
                Text("Upload image")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .padding(.top, 0)
        .onChange(of: viewModel.selectedItem) { newValue in
            viewModel.setImage(pickedImage: newValue)
        }
    }
}

extension CheckInSheetView {
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
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var selectedItem: PhotosPickerItem? = nil
        @Published var activeSheet: Sheet?
        @Published var review: String = ""
        @Published var rating: Double = 0
        @Published var manufacturer: Company? = nil
        @Published var servingStyles = [ServingStyle]()
        @Published var servingStyle = ServingStyleName.none
        @Published var taggedFriends = [Profile]()
        @Published var pickedFlavors = [Flavor]()
        @Published var location: Location?
        @Published var image: UIImage?

        func loadFromCheckIn(checkIn: CheckIn) {
            review = checkIn.review ?? ""
            rating = checkIn.rating ?? 0
            manufacturer = checkIn.variant?.manufacturer
            servingStyle = checkIn.servingStyle?.name ?? ServingStyleName.none
            taggedFriends = checkIn.taggedProfiles
            pickedFlavors = checkIn.flavors
            location = checkIn.location
        }

        func activateSheet(_ sheet: Sheet) {
            DispatchQueue.main.async {
                self.activeSheet = sheet
            }
        }

        func setFlavors(_ flavors: [Flavor]) {
            DispatchQueue.main.async {
                self.pickedFlavors = flavors
            }
        }

        func setLocation(_ location: Location) {
            DispatchQueue.main.async {
                self.location = location
            }
        }

        func setManufacturer(_ company: Company) {
            DispatchQueue.main.async {
                self.manufacturer = company
            }
        }

        func setImage(pickedImage: PhotosPickerItem?) {
            Task {
                if let imageData = try await pickedImage?.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            }
        }

        func updateCheckIn(_ checkIn: CheckIn, _ onUpdate: @escaping (_ checkIn: CheckIn) -> Void) {
            let updateCheckInParams = UpdateCheckInParams(checkIn: checkIn, product: checkIn.product, review: review, taggedFriends: taggedFriends, servingStyle: servingStyles.first(where: { $0.name == servingStyle }), manufacturer: manufacturer, flavors: pickedFlavors, rating: rating, location: location)

            Task {
                switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
                case let .success(updatedCheckIn):
                    onUpdate(updatedCheckIn)
                case let .failure(error):
                    print(error)
                }
            }
        }

        func createCheckIn(_ product: ProductJoined, _ onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
            let newCheckParams = NewCheckInParams(product: product, review: review, taggedFriends: taggedFriends, servingStyle: servingStyles.first(where: { $0.name == servingStyle }), manufacturer: manufacturer, flavors: pickedFlavors, rating: rating, location: location)

            Task {
                switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
                case let .success(newCheckIn):
                    if let data = image?.jpegData(compressionQuality: 0.3) {
                        switch await repository.checkIn.uploadImage(id: newCheckIn.id, profileId: repository.auth.getCurrentUserId(), data: data) {
                        default:
                            break
                        }
                    }

                    onCreation(newCheckIn)
                case let .failure(error):
                    print(error)
                }
            }
        }

        func loadInitialData(product: ProductJoined) {
            if let categoryId = product.subcategories.first?.category.id {
                Task {
                    switch await repository.category.getServingStylesByCategory(categoryId: categoryId) {
                    case let .success(categoryServingStyles):
                        await MainActor.run {
                            self.servingStyles = categoryServingStyles.servingStyles
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
}
