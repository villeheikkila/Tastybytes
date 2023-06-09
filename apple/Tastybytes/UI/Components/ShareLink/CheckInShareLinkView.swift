import SwiftUI

struct CheckInShareLinkView: View {
    let checkIn: CheckIn
    
    var body: some View {
            ShareLink("Share Check-in", item: NavigatablePath.checkIn(id: checkIn.id).url, preview: SharePreview(
                checkIn.product.getDisplayName(.fullName)))
    }
}
