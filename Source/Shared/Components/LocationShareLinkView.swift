
import Models
import SwiftUI

public struct LocationShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let location: Location.Saved

    public init(location: Location.Saved) {
        self.location = location
    }

    private var link: URL {
        NavigatablePath.location(id: location.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    private var title: String {
        location.name
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("location.shareLink.subject"), message: Text(title))
    }
}
