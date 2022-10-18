import CachedAsyncImage
import GoTrue
import SwiftUI

struct CheckInCardView: View {
    let checkIn: CheckIn
    
    var body: some View {
        HStack {
            VStack {
                header
                productSection
                if !checkIn.isEmpty() {
                    checkInSection
                }
                footer
            }
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
        }
        .padding(.all, 10)
    }

    var header: some View {
        NavigationLink(value: checkIn.profile) {
            HStack {
                AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 30, id: checkIn.profile.id)
                Text(checkIn.profile.username)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding([.trailing, .leading, .top], 10)
        }
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

                    Spacer()
                }
            }
            .padding([.trailing, .leading], 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.trailing, .leading], 5)
    }

    var checkInSection: some View {
        NavigationLink(value: checkIn) {
            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let rating = checkIn.rating {
                        RatingView(rating: rating)
                    }

                    if let review = checkIn.review {
                        Text(review)
                            .fontWeight(.medium)
                    }

                    if let flavors = checkIn.flavors {
                        HStack {
                            ForEach(flavors) { flavor in
                                ChipView(title: flavor.name, cornerRadius: 5)
                            }
                        }
                    }
                }
                .padding(.all, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

                if checkIn.taggedProfiles.count > 0 {
                    VStack {
                        HStack {
                            Text(verbatim: "Tagged friends").font(.subheadline).fontWeight(.medium)
                            Spacer()
                        }
                        HStack {
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
            .padding([.trailing, .leading], 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    var footer: some View {
        HStack {
            NavigationLink(value: checkIn) {
                Text(checkIn.createdAt.formatted())
                    .font(.system(size: 12, weight: .medium, design: .default))
                Spacer()
            }
            .buttonStyle(PlainButtonStyle())
            ReactionsView(checkInId: checkIn.id, checkInReactions: checkIn.checkInReactions)
        }
        .frame(height: 24)
        .padding([.trailing, .leading, .bottom], 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
