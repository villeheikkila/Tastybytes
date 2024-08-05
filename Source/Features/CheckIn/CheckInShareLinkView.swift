
import Models
import SwiftUI

public struct CheckInShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let checkIn: CheckIn.Joined

    public init(checkIn: CheckIn.Joined) {
        self.checkIn = checkIn
    }

    private var link: URL {
        NavigatablePath.checkIn(id: checkIn.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    private var title: LocalizedStringKey {
        "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))"
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("checkIn.shareLink.subject"), message: Text(title))
    }
}
