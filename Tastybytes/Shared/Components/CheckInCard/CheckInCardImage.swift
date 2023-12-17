import Components
import Models
import SwiftUI

struct CheckInCardImage: View {
    @State private var showFullPicture = false
    @State private var blurHashPlaceHolder: UIImage?

    let imageUrl: URL?
    let blurHash: CheckIn.BlurHash?

    var body: some View {
        if let imageUrl {
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
                        .popover(isPresented: $showFullPicture) {
                            RemoteImage(url: imageUrl) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                } else {
                    BlurHashPlaceholder(blurHash: blurHash, height: 200)
                }
            }
            .frame(height: 200)
            .padding(.vertical, 4)
        }
    }
}
