
import SwiftUI

struct IncludedLibrariesScreen: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        List(appModel.includedLibraries) { includedLibrary in
            Link(destination: includedLibrary.link) {
                Text(includedLibrary.name)
            }
        }
        .listStyle(.plain)
        .navigationTitle("includedLibraries.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
