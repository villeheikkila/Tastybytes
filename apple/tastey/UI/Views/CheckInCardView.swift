import CachedAsyncImage
import GoTrue
import SwiftUI

struct CheckInCardView: View {
    let checkIn: CheckIn

    var body: some View {
        NavigationLink(value: checkIn) {
            HStack {
                VStack {
                   header

                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            productSection

                            Spacer()
                            

                            if let flavors = checkIn.flavors {
                                HStack {
                                    ForEach(flavors) { flavor in
                                        ChipView(title: flavor.name)
                                    }
                                }
                            }
                            
                            HStack {
                                RatingView(rating: checkIn.rating ?? 0)
                                    .padding(.bottom, 10)
                            }
                            
                            if let review = checkIn.review {
                                Text(review).foregroundColor(.primary)
                            }

                            if checkIn.taggedProfiles.count > 0 {
                                VStack {
                                    HStack {
                                        Text(verbatim: "Tagged friends").font(.subheadline).fontWeight(.medium)
                                        Spacer()
                                    }
                                    HStack{
                                        ForEach(checkIn.taggedProfiles, id: \.id) {
                                            taggedProfile in
                                            NavigationLink(value: taggedProfile) {
                                                AvatarView(avatarUrl: taggedProfile.getAvatarURL(), size: 32, id: taggedProfile.id)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
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
                    
                    footer

                }
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
            }
            .padding(.all, 10)
        }
        .buttonStyle(PlainButtonStyle())

    }
    
    var header: some View {
        NavigationLink(value: checkIn.profile) {
            HStack {
                AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 30, id: checkIn.profile.id)
                Text(checkIn.profile.username)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .cornerRadius(10)
            .padding(.trailing, 10)
            .padding(.leading, 10)
            .padding(.top, 10)
        }
    }
    
    var footer: some View {
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

    
    var productSection: some View {
        NavigationLink(value: checkIn.product) {
            VStack(alignment: .leading) {
                    Text(checkIn.product.getDisplayName(.fullName))
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.primary)
            
                
                HStack {
                    Text(checkIn.product.getDisplayName(.brandOwner))
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.secondary)

                    if let manufacturerName = checkIn.variant?.manufacturer.name {
                        Text("(\(manufacturerName))")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
