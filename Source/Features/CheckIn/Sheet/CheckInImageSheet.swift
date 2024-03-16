import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInImageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    let checkIn: CheckIn
    let imageUrl: URL

    private let minScaleFactor = 0.8

    var body: some View {
        VStack(alignment: .center) {
            RemoteImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { scaleFactor in
                                    guard scaleFactor > minScaleFactor else { return }
                                    scale = scaleFactor.magnitude
                                }
                        )
                } else {
                    ProgressView()
                }
            }
        }
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
                ImageShareLink(url: imageUrl, title: "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))")
            }
        }
    }
}
