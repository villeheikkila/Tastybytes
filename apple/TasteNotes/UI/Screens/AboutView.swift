import SwiftUI

struct AboutScreenView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Hi! I'm Ville, the sole developer of the TasteNote app which I started as passion project to fill the void space between various tasting logging apps. The app is open source and licensed under the MIT license.")
            }.padding(.all, 20)
            
            List {
                Link(destination: URL(string: "https://github.com/villeheikkila/TasteNotes")!) {
                    Label("GitHub", systemImage: "github")
                        .fontWeight(.medium)
                }
                Link(destination: URL(string: "https://villeheikkila.com")!) {
                    Label("Portfolio", systemImage: "safari")
                        .fontWeight(.medium)
                }
                Link(destination: URL(string: "www.linkedin.com/in/heikkilaville")!) {
                    Label("LinkedIn", systemImage: "linkedin")
                        .fontWeight(.medium)
                }
            }
            
            Spacer()

        }
        .navigationTitle("About")
    }
}

struct AboutScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AboutScreenView()
    }
}
