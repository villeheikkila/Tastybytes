import EnvironmentModels
import Models
import SwiftUI

public struct LocationShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let location: Location

    public init(location: Location) {
        self.location = location
    }

    private var title: String {
        location.name
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.location(id: location.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl), preview: SharePreview(title))
    }
}
