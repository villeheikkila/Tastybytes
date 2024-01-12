import EnvironmentModels
import Models
import SwiftUI

public struct CheckInShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let checkIn: CheckIn

    public init(checkIn: CheckIn) {
        self.checkIn = checkIn
    }

    private var title: String {
        "\(checkIn.profile.preferredName) had \(checkIn.product.getDisplayName(.fullName))"
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl), preview: SharePreview(title))
    }
}
