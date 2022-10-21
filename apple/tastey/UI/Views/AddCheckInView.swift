import SwiftUI
import WrappingHStack

struct AddCheckInView: View {
    let product: Product
    @State var activeSheet: Sheet?
    @State var review: String = ""
    @State var rating: Int? = nil
    @State var manufacturer: Company? = nil

    @State var servingStyles = [ServingStyle]()
    @State var servingStyle = ServingStyleName.none

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
                        RatingPickerView(rating: $rating)
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
                                WrappingHStack(taggedFriends, id: \.self) {
                                    friend in
                                        AvatarView(avatarUrl: friend.getAvatarURL(), size: 24, id: friend.id)
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
                    leading: Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .bold()
                    },
                    trailing: Button(action: { createCheckIn() }) {
                        Text("Check-in!")
                            .bold()
                    })
                .task {
                    loadInitialData(product: product)
                }
            }
        }
    }

    func createCheckIn() {
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
                    let categoryServingStyles = try await repository.category.getServingStylesByCategory(categoryId: categoryId)
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
