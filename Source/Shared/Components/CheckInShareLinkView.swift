import EnvironmentModels
import Models
import SwiftUI

public struct CheckInShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let checkIn: CheckIn

    public init(checkIn: CheckIn) {
        self.checkIn = checkIn
    }

    private var link: URL {
        NavigatablePath.checkIn(id: checkIn.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: LocalizedStringKey {
        "checkIn.shareLink.title \(checkIn.profile.preferredName) \(checkIn.product.formatted(.fullName))"
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("checkIn.shareLink.subject"), message: Text(title))
    }
}
