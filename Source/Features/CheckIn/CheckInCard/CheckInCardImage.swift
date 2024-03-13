import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInCardImage: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var showFullPicture = false
    @State private var blurHashPlaceHolder: UIImage?

    let checkIn: CheckIn

    var body: some View {
        if let imageUrl = checkIn.getImageUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
            RemoteImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showFullPicture = true
                        }
                        .accessibility(addTraits: .isButton)
                        .sheet(isPresented: $showFullPicture) {
                            CheckInCardImagePopover(checkIn: checkIn, imageUrl: imageUrl)
                        }
                        .presentationBackground(.thinMaterial)
                } else {
                    BlurHashPlaceholder(blurHash: checkIn.images.first?.blurHash, height: 200)
                }
            }
            .frame(height: 200)
            .padding(.vertical, 4)
        }
    }
}

struct CheckInCardImagePopover: View {
    @Environment(\.dismiss) private var dismiss
    let checkIn: CheckIn
    let imageUrl: URL

    var body: some View {
        NavigationStack {
            RemoteImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .ignoresSafeArea(.all)
            .safeAreaInset(edge: .bottom, content: {
                HStack(alignment: .top) {
                    HStack(alignment: .center) {
                        Avatar(profile: checkIn.profile)
                            .avatarSize(.large)
                        VStack(alignment: .leading) {
                            Text(checkIn.profile.preferredName)
                                .font(.caption).bold()
                                .foregroundColor(.primary)
                            if let location = checkIn.location {
                                Text(location.formatted(.withEmoji))
                                    .font(.caption).bold()
                                    .foregroundColor(.primary)
                                    .contentShape(Rectangle())
                            }
                        }
                        Spacer()
                        if let checkInAt = checkIn.checkInAt {
                            Text(checkInAt.formatted(.customRelativetime))
                                .font(.caption)
                                .bold()
                        } else {
                            Text("checkIn.legacy.label")
                                .font(.caption)
                                .bold()
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            })
            .toolbar {
                ToolbarDismissAction()
                ToolbarItemGroup(placement: .primaryAction) {
                        ImageShareLink(url: imageUrl)
                }
            }
        }
    }
}

struct ImageShareLink: View {
    let url: URL

    var transferable: ImageTransferable {
        ImageTransferable(url: url)
    }

    var body: some View {
        ShareLink(item: transferable, preview: .init("img", image: transferable))
    }
}

struct ImageTransferable: Codable, Transferable {
    let url: URL

    func fetchImageData() async -> Data {
        do {
            return try await URLSession.shared.data(from: url).0
        } catch {
            return Data()
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { transferable in
            await transferable.fetchImageData()
        }
    }
}
