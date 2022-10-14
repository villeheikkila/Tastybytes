import CachedAsyncImage
import GoTrue
import SwiftUI

struct CheckInCardView: View {
    let checkIn: CheckIn

    var body: some View {
        NavigationLink(value: checkIn) {
            HStack {
                VStack {
                    NavigationLink(value: checkIn.profiles) {
                        HStack {
                            Avatar(avatarUrl: checkIn.profiles.avatarUrl, size: 30, id: checkIn.profiles.id)
                            Text(checkIn.profiles.username)
                                .font(.system(size: 12, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .cornerRadius(10)
                        .padding(.trailing, 10)
                        .padding(.leading, 10)
                        .padding(.top, 10)
                    }
                    
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            NavigationLink(value: checkIn.products) {
                                VStack(alignment: .leading) {
                                    Text(checkIn.products.subBrand.brands.name)
                                        .font(.system(size: 18, weight: .bold, design: .default))
                                        .foregroundColor(.primary)
                                    if checkIn.products.subBrand.name != "" {
                                        Text(checkIn.products.subBrand.name)
                                            .font(.system(size: 24, weight: .bold, design: .default))
                                            .foregroundColor(.primary)
                                    }
                                    Text(checkIn.products.name)
                                        .font(.system(size: 24, weight: .bold, design: .default))
                                        .foregroundColor(.primary)
                                    Text(checkIn.products.subBrand.brands.companies.name)
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            if let review = checkIn.review {
                                Text(review).foregroundColor(.primary)
                            }
                            HStack {
                                RatingView(rating: checkIn.rating ?? 0)
                                    .padding(.bottom, 10)
                            }
                        }
                        .padding(.all, 10)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    
                    HStack {
                        Text(checkIn.createdAt).font(.system(size: 12, weight: .medium, design: .default))
                        Spacer()
                        ReactionsView(checkInId: checkIn.id, checkInReactions: checkIn.checkInReactions)
                    }
                    .padding(.trailing, 8)
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(10)
                }
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
            }
            .padding(.all, 10)
            .frame(height: 280)
        }
    }
}
