import SwiftUI

struct AddCheckInView: View {
    let product: Product
    @State var activeSheet: Sheet?
    @State var review: String = ""
    @State var rating: Int? = nil
    @State var manufacturer: Company? = nil

    @State var servingStyles = [ServingStyle]()
    @State var servingStyle = ServingStyleName.none

    @State var friends = [Profile]()
    @State var taggedFriends = [Profile]()

    @State var availableFlavors = [Flavor]()
    @State var pickedFlavors = [Flavor]()

    @Environment(\.dismiss) var dismiss
    let onCreation: (_ checkIn: CheckIn) -> Void

    var body: some View {
        NavigationStack {
            VStack {
                ProductCardView(product: product)
                Form {
                    Section {
                        TextField("How was it?", text: $review)
                        RatingPicker(rating: $rating)
                        Button(action: {
                            self.activeSheet = Sheet.flavors
                        }) {
                            HStack {
                                if pickedFlavors.count != 0 {
                                    ForEach(pickedFlavors, id: \.self) {
                                        flavor in ChipView(title: flavor.name)
                                    }
                                } else {
                                    Text("Flavors")
                                }
                            }
                        }
                    } header: {
                        Text("Review")
                    }.headerProminence(.increased)

                    Section {
                        if servingStyles.count > 0 {
                            Picker("Serving Style", selection: $servingStyle) {
                                Text("Not Selected").tag(ServingStyleName.none)
                                ForEach(servingStyles.map { $0.name }) { servingStyle in
                                    Text(servingStyle.rawValue.capitalized)
                                }
                            }
                        }

                        Button(action: { self.activeSheet = Sheet.manufacturer }) {
                            Text(manufacturer?.name ?? "Manufactured by")
                        }
                    }

                    Section {
                        Button(action: { self.activeSheet = Sheet.friends }) {
                            if taggedFriends.count == 0 {
                                Text("Tag friends")
                            } else {
                                ForEach(taggedFriends, id: \.id) {
                                    friend in
                                    HStack {
                                        AvatarView(avatarUrl: friend.getAvatarURL(), size: 24, id: friend.id)
                                        Text(friend.username)
                                    }.padding(.all, 3)
                                        .foregroundColor(.white)
                                        .background(Color(.systemBlue))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(.systemBlue), lineWidth: 1.5)
                                        )
                                }
                            }
                        }
                    }
                }
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .friends:
                        FriendPickerView(taggedFriends: $taggedFriends)
                    case .flavors:
                        FlavorPickerView(availableFlavors: $availableFlavors, pickedFlavors: $pickedFlavors)
                    case .manufacturer:
                        CompanySearchView(onSelect: { company, _ in
                            self.manufacturer = company
                        })
                    }
                }
                .navigationBarItems(
                    leading: Button(action: {createCheckIn()}) {
                        Text("Check-in!").bold()
                    },
                    trailing: Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .bold()
                    })
                .task {
                    loadInitialData(product: product)
                }
            }
        }
    }

    func createCheckIn() {
        let friendIds = friends.map { $0.id }
        let servingStyleId = servingStyles.first(where: { $0.name == servingStyle })?.id
        let manufacturerId = manufacturer?.id
        let flavorIds = pickedFlavors.map { $0.id }
        var ratingDoubled: Int? = nil
        
        if let rating = rating {
            ratingDoubled = Int(rating * 2)
        }

        let newCheckParams = NewCheckInParams(productId: product.id, rating: ratingDoubled, review: review, manufacturerId: manufacturerId, servingStyleId: servingStyleId, friendIds: friendIds, flavorIds: flavorIds)

        print(newCheckParams    )
        Task {
            do {
                let newCheckIn = try await SupabaseCheckInRepository().createCheckIn(newCheckInParams: newCheckParams)
                onCreation(newCheckIn)
                dismiss()
            } catch {
                print("error: \(error)")
            }
        }
    }

    func loadInitialData(product: Product) {
        Task {
            if let categoryId = product.subcategories.first?.category.id {
                do {
                    let categoryServingStyles = try await SupabaseCategoryRepository().loadServingStyles(categoryId: categoryId)
                    self.servingStyles = categoryServingStyles.servingStyles
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }

    enum Sheet: Identifiable {
        var id: Self { self }
        case manufacturer
        case friends
        case flavors
    }
}
