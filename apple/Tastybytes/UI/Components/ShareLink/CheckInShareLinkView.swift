import SwiftUI

struct CheckInShareLinkView: View {
    let checkIn: CheckIn
    
    var title: String {
        "\(checkIn.profile.preferredName) had \(checkIn.product.getDisplayName(.fullName))"
    }
    
    var body: some View {
            ShareLink("Share Check-in", item: NavigatablePath.checkIn(id: checkIn.id).url, preview: SharePreview(title))
    }
}
