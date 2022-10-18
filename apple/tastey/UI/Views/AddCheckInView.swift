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

    @Environment(\.dismiss) var dismiss
    let onCreation: (_ checkIn: CheckIn) -> Void

    var body: some View {
        VStack {
            ProductCardView(product: product)
            Form {
                Section {
                    TextField("How was it?", text: $review)
                    RatingPicker(rating: $rating)
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
                
                Button("Check-in!", action: {
                    createCheckIn()
                })
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .friends:
                    FriendPickerView(friends: friends, taggedFriends: $taggedFriends)
                case .manufacturer:
                    CompanySearchView(onSelect: { company, createdNew in
                        self.manufacturer = company
                    })
                }
            }
        }
        .task {
            loadInitialData(product: product)
        }}
        
        func createCheckIn() {
            let friendIds = friends.map { $0.id }
            let servingStyleId = servingStyles.first(where: {$0.name == servingStyle})?.id
            let manufacturerId = manufacturer?.id
            
            let newCheckParams = NewCheckInParams(productId: product.id, rating: rating, review: review, manufacturerId: manufacturerId, servingStyleId: servingStyleId, friendIds: friendIds)
                        
            Task {
                do {
                    let newCheckIn = try await SupabaseCheckInRepository().createCheckIn(newCheckInParams: newCheckParams)
                    
                    print(newCheckIn)
                    onCreation(newCheckIn)
                    dismiss()
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
    func loadInitialData(product: Product) {
        let currentUserId = SupabaseAuthRepository().getCurrentUserId()
        Task {
            let acceptedFriends = try await SupabaseFriendsRepository().loadAcceptedByUserId(userId: currentUserId)
            
            self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId)}
            print(self.friends)
        }
        
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
        }

}
