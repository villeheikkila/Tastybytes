import SwiftUI
import WrappingHStack

struct AddCheckInView: View {
    let product: ProductJoined
    let onCreation: (_ checkIn: CheckIn) -> Void
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                ProductCardView(product: product)
                Form {
                    Section {
                        TextField("How was it?", text: $viewModel.review)
                        RatingPickerView(rating: $viewModel.rating)
                        Button(action: {
                            viewModel.activeSheet = Sheet.flavors
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
                        
                        Button(action: { viewModel.activeSheet = Sheet.manufacturer }) {
                            Text(viewModel.manufacturer?.name ?? "Manufactured by")
                        }
                    }
                    
                    Section {
                        Button(action: { viewModel.activeSheet = Sheet.friends }) {
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
                }
                .sheet(item: $viewModel.activeSheet) { sheet in
                    switch sheet {
                    case .friends:
                        FriendPickerView(taggedFriends: $viewModel.taggedFriends)
                    case .flavors:
                        FlavorPickerView(availableFlavors: $viewModel.availableFlavors, pickedFlavors: $viewModel.pickedFlavors)
                    case .manufacturer:
                        CompanySearchView(onSelect: { company, _ in
                            viewModel.manufacturer = company
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
                    trailing: Button(action: { viewModel.createCheckIn(product, {
                        newCheckIn in
                        onCreation(newCheckIn)
                        dismiss()
                    }) }) {
                        Text("Check-in!")
                            .bold()
                    })
                .task {
                    viewModel.loadInitialData(product: product)
                }
            }
        }
    }
    

    

}

extension AddCheckInView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case manufacturer
        case friends
        case flavors
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var activeSheet: Sheet?
        @Published var review: String = ""
        @Published var rating: Int? = nil
        @Published var manufacturer: Company? = nil
        @Published var servingStyles = [ServingStyle]()
        @Published var servingStyle = ServingStyleName.none
        @Published var taggedFriends = [Profile]()
        @Published var availableFlavors = [Flavor]()
        @Published var pickedFlavors = [Flavor]()
        
        func createCheckIn(_ product: ProductJoined, _ onCreation: @escaping (_ checkIn: CheckIn) -> Void) {
            let friendIds = taggedFriends.map { $0.id }
            let servingStyleId = servingStyles.first(where: { $0.name == servingStyle })?.id
            let manufacturerId = manufacturer?.id
            let flavorIds = pickedFlavors.map { $0.id }
            var ratingDoubled: Int?
            
            if let rating = rating {
                ratingDoubled = Int(rating * 2)
            }
            
            let newCheckParams = NewCheckInParams(productId: product.id, rating: ratingDoubled, review: review, manufacturerId: manufacturerId, servingStyleId: servingStyleId, friendIds: friendIds, flavorIds: flavorIds)
            
            Task {
                do {
                    let newCheckIn = try await repository.checkIn.create(newCheckInParams: newCheckParams)
                    onCreation(newCheckIn)
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
        func loadInitialData(product: ProductJoined) {
            Task {
                if let categoryId = product.subcategories.first?.category.id {
                    do {
                        let categoryServingStyles = try await repository.category.getServingStylesByCategory(categoryId: categoryId)
                        self.servingStyles = categoryServingStyles.servingStyles
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
}
