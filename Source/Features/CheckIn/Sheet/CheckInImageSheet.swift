import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInImageSheet: View {
    @Environment(\.dismiss) private var dismiss
    let checkIn: CheckIn
    let imageUrl: URL

    var body: some View {
        VStack(alignment: .center) {
            ControllableImage(imageUrl: imageUrl)
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

@MainActor
struct ControllableImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var location: CGPoint?
    let imageUrl: URL

    private let minScaleFactor = 0.8
    
    var dragGesture: some Gesture{
        DragGesture()
            .onChanged { value in
                guard scale != 1.0 else { return }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    self.location = value.location
                }
            }
    }
    
    var zoomGesture: some Gesture{
        MagnificationGesture()
            .onChanged { scaleFactor in
                guard scaleFactor > minScaleFactor else { return }
                scale = scaleFactor.magnitude
            }
    }

    var body: some View {
            GeometryReader { geometry in
                RemoteImage(url: imageUrl) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(8)
                            .scaleEffect(scale)
                            .position(location ?? .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
                            .simultaneousGesture(zoomGesture)
                            .simultaneousGesture(dragGesture)
                            .frame(size: .init(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8))
                            .onTapGesture(count: 2) {
                                scale = 1
                                location = .init(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            }
                    } else {
                        ProgressView()
                    }
                }
            }
    }
}
