import EnvironmentModels
import Models
import SwiftUI

public struct LocationShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let location: Location.Saved

    public init(location: Location.Saved) {
        self.location = location
    }

    private var link: URL {
        NavigatablePath.location(id: location.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: String {
        location.name
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("location.shareLink.subject"), message: Text(title))
    }
}
