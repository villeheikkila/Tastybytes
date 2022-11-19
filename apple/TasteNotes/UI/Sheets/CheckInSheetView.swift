import PhotosUI
import SwiftUI
import WrappingHStack

struct CheckInSheetView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @State var showPhotoMenu = false

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

                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150, alignment: .top)
                        .shadow(radius: 4)
                }

                Button(action: {
                    showPhotoMenu.toggle()
                }) {
                    Label("Add Photo", systemImage: "photo")
                }

                Form {
                    Section {
                        TextField("How was it?", text: $viewModel.review, axis: .vertical)
                        RatingPickerView(rating: $viewModel.rating)
                        Button(action: {
                            viewModel.setActiveSheet(.flavors)
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
                            viewModel.setActiveSheet(.manufacturer)
                        }) {
                            Text(viewModel.manufacturer?.name ?? "Manufactured by")
                        }
                    }

                    Section {
                        Button(action: {
                            viewModel.setActiveSheet(.friends)
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
                    case .photoPicker:
                        LegacyPhotoPicker(onSelection: {
                            image in viewModel.setImageFromPicker(pickedImage: image)
                        })
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
        case photoPicker
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var selectedItem: PhotosPickerItem? = nil
        @Published var activeSheet: Sheet?
        @Published var showCamera = false
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

        func setActiveSheet(_ sheet: Sheet) {
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

        func setImageFromCamera(_ image: UIImage) {
            Task {
                await MainActor.run {
                    self.image = image
                    self.showCamera = false
                }
            }
        }

        func setImageFromPicker(pickedImage: UIImage) {
            Task {
                await MainActor.run {
                    self.image = pickedImage
                }
            }
        }

        func updateCheckIn(_ checkIn: CheckIn, _ onUpdate: @escaping (_ checkIn: CheckIn) -> Void) {
            let updateCheckInParams = UpdateCheckInParams(checkIn: checkIn, product: checkIn.product, review: review, taggedFriends: taggedFriends, servingStyle: servingStyles.first(where: { $0.name == servingStyle }), manufacturer: manufacturer, flavors: pickedFlavors, rating: rating, location: location)

            Task {
                switch await repository.checkIn.update(updateCheckInParams: updateCheckInParams) {
                case let .success(updatedCheckIn):
                    onUpdate(updatedCheckIn)
                    uploadImage(checkIn: updatedCheckIn)
                case let .failure(error):
                    print("error: \(error)")
                }
            }
        }

        func createCheckIn(_ product: ProductJoined, _ onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
            let newCheckParams = NewCheckInParams(product: product, review: review, taggedFriends: taggedFriends, servingStyle: servingStyles.first(where: { $0.name == servingStyle }), manufacturer: manufacturer, flavors: pickedFlavors, rating: rating, location: location)

            Task {
                switch await repository.checkIn.create(newCheckInParams: newCheckParams) {
                case let .success(newCheckIn):
                    uploadImage(checkIn: newCheckIn)
                    onCreation(newCheckIn)
                case let .failure(error):
                    print(error)
                }
            }
        }
        
        func uploadImage(checkIn: CheckIn) {
            Task {
                if let data = image?.jpegData(compressionQuality: 0.3) {
                    switch await repository.checkIn.uploadImage(id: checkIn.id, data: data) {
                    case let .failure(error):
                        print(error)
                    default:
                        break
                    }
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
