
import CachedAsyncImage
import GoTrue
import SwiftUI
import WrappingHStack

struct CheckInCardView: View {
    let checkIn: CheckIn
    let loadedFrom: LoadedFrom
    let onDelete: (_ checkIn: CheckIn) -> Void
    let onUpdate: (_ checkIn: CheckIn) -> Void
    @StateObject var viewModel = ViewModel()
    @State var showDeleteCheckInConfirmationDialog = false
    
    func isOwnedByCurrentUser() -> Bool {
        return checkIn.profile.id == repository.auth.getCurrentUserId()
    }

    func avoidStackingCheckInPage() -> Bool {
        var isCurrentProfile: Bool

        switch loadedFrom {
        case let .profile(profile):
            isCurrentProfile = profile.id == checkIn.profile.id
        default:
            isCurrentProfile = false
        }

        return isCurrentProfile
    }

    var body: some View {
        CardView {
            VStack {
                header
                productSection
                if !checkIn.isEmpty() {
                    checkInSection
                }
                footer
            }
            .padding(.all, 10)
        }
        .sheet(isPresented: $viewModel.showingSheet) {
            CheckInSheetView(checkIn: checkIn, onUpdate: {
                updatedCheckIn in onUpdate(updatedCheckIn)
            })
        }
        .contextMenu {
            if isOwnedByCurrentUser() {
                Button(action: {
                    viewModel.toggleSheet()
                }) {
                    Label("Edit", systemImage: "pencil")
                }

                Button(action: {
                    showDeleteCheckInConfirmationDialog.toggle()
                }) {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
        .confirmationDialog("delete_check_in",
                            isPresented: $showDeleteCheckInConfirmationDialog
        ) {
            Button("Permanently delete the check-in", role: .destructive, action: {
                    viewModel.delete(checkIn: checkIn, onDelete: onDelete)
            })
        }
    }

    var header: some View {
        NavigationLink(value: checkIn.profile) {
            HStack {
                AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 30, id: checkIn.profile.id)
                Text(checkIn.profile.getPreferredName())
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .disabled(avoidStackingCheckInPage())
    }

    var backgroundImage: some View {
        HStack {
            if let imageUrl = checkIn.getImageUrl() {
                CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }

    var productSection: some View {
        NavigationLink(value: checkIn.product) {
            VStack(alignment: .leading) {
                Text(checkIn.product.getDisplayName(.fullName))
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.primary)

                HStack {
                    NavigationLink(value: checkIn.product.subBrand.brand.brandOwner) {
                        Text(checkIn.product.getDisplayName(.brandOwner))
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }

                    if let manufacturer = checkIn.variant?.manufacturer, manufacturer.id != checkIn.product.subBrand.brand.brandOwner.id {
                        NavigationLink(value: manufacturer) {
                            Text("(\(manufacturer.name))")
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                        }
                    }

                    Spacer()
                }
            }
        }
        .disabled(loadedFrom == LoadedFrom.product)
        .buttonStyle(.plain)
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
                        WrappingHStack(flavors, id: \.self) {
                            flavor in
                            ChipView(title: flavor.name.capitalized, cornerRadius: 5).padding(.all, 2)
                        }
                    }
                }
                .padding(.all, 10)
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
        }
        .disabled(loadedFrom == LoadedFrom.checkIn)
        .buttonStyle(.plain)
    }

    var footer: some View {
        HStack {
            NavigationLink(value: checkIn) {
                Text(checkIn.createdAt.formatted())
                    .font(.system(size: 12, weight: .medium, design: .default))

                Spacer()
            }
            .buttonStyle(.plain)
            .disabled(loadedFrom == LoadedFrom.checkIn)
            Spacer()
            ReactionsView(checkIn: checkIn)
        }
    }
}

extension CheckInCardView {
    enum LoadedFrom: Equatable {
        case checkIn
        case product
        case profile(Profile)
        case activity(Profile)
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var showingSheet = false

        func toggleSheet() {
            showingSheet.toggle()
        }

        func delete(checkIn: CheckIn, onDelete: @escaping (_ checkIn: CheckIn) -> Void) {
            Task {
                try await repository.checkIn.delete(id: checkIn.id)
                onDelete(checkIn)
            }
        }
    }
}
