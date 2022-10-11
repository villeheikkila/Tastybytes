import SwiftUI
import CachedAsyncImage

struct SimpleCheckIn {
    let name: String
    let subBrandName: String
    let brandName: String
    let companyName: String
    let rating: Double
    let creator: String
}

struct ActivityView: View {
    @StateObject private var model = ActivityViewModel()

    var body: some View {
        ScrollView {
            ForEach(model.checkIns, id: \.id) { checkIn in
                ProductCardView(checkIn: checkIn)
            }
        }.task() {
            model.getActivityFeed()
        }
    }
}

struct ProductCardView: View {
    var checkIn: CheckInResponse
    @StateObject private var model = ProductCardViewModel()


    var body: some View {
        HStack {
            VStack {
                HStack {
                    if let avatarUrL = checkIn.profiles.avatar_url {
                        CachedAsyncImage(url: getAvatarURL(avatarUrl: avatarUrL)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                    }
                    Text(checkIn.profiles.username)
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .cornerRadius(10).padding(.trailing, 10).padding(.leading, 10).padding(.top, 10)

                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Spacer()

                        Text(checkIn.products.sub_brands.brands.name)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        if (checkIn.products.sub_brands.name != "") {
                            Text(checkIn.products.sub_brands.name)
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        Text(checkIn.products.name)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text(checkIn.products.sub_brands.brands.companies.name)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.gray)

                        Spacer()
                        HStack {
                            RatingView(rating: checkIn.rating ?? 0)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding(.all, 10)

                    Spacer()

                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(.darkGray))
                .cornerRadius(5)
                .padding(.leading, 5)
                .padding(.trailing, 5)

                HStack {
                    if let createdAt = checkIn.created_at {
                        Text(createdAt).font(.system(size: 12, weight: .medium, design: .default))
                    }
                    Spacer()
                    ForEach(checkIn.check_in_reactions, id: \.id) {
                        reaction in MiniAvatar(avatarUrl: reaction.profiles.avatar_url)
                    }
                    Button {
                        model.reactToCheckIn(checkInId: checkIn.id)
                    } label: {
                        Text("\(checkIn.check_in_reactions.count)").font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(.black)
                        Image(systemName: "hand.thumbsup.fill").frame(alignment: .leading).foregroundColor(Color(.systemYellow))
                    }
                }.padding(.trailing, 8).padding(.leading, 8).padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(10)
            }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)

        }.padding(.all, 10)
    }
}


struct MiniAvatar: View {
    let avatarUrl: String?
    
    var body: some View {
        if let avatarUrL = avatarUrl {
            CachedAsyncImage(url: getAvatarURL(avatarUrl: avatarUrL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 24, height: 24)
        } else {
            Text("HEI")
        }
    }
}

extension ActivityView {
    @MainActor class ActivityViewModel: ObservableObject {
        @Published var checkIns = [CheckInResponse]()

        func getActivityFeed() {
            Task {
                let response = try await API.supabase.database
                    .rpc(fn: "fnc__get_activity_feed")
                    .select(columns: "id, rating, review, created_at, profiles (id, username, avatar_url), products (id, name, description, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), check_in_reactions (id, created_by, profiles (id, username, avatar_url))")
                    .limit(count: 2)
                    .execute()

                let result = try response.decoded(to: [CheckInResponse].self)
    
                DispatchQueue.main.async {
                    self.checkIns = result
                }
            }
        }
    }
}

extension ProductCardView {
    @MainActor class ProductCardViewModel: ObservableObject {
        struct CheckInReactionRequest: Encodable {
            let check_in_id: Int
            let created_by: UUID
        }
        
        func reactToCheckIn(checkInId: Int) {
            let query = API.supabase.database.from("check_in_reactions")
                .insert(values: CheckInReactionRequest(check_in_id: checkInId, created_by: getCurrentUserIdUUID()))
            
            Task {
                try await query.execute()
            }
        }
    }
}

