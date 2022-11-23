import SwiftUI

struct AboutScreenView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            if let aboutPage = viewModel.aboutPage {
                HStack {
                    Text(aboutPage.summary)
                }.padding(.all, 20)
                
                List {
                    Link(destination: URL(string: aboutPage.githubUrl)!) {
                        Label("GitHub", image: "linkedin-fill")
                            .fontWeight(.medium)
                    }
                    Link(destination: URL(string: aboutPage.portfolioUrl)!) {
                        Label("Portfolio", systemImage: "safari")
                            .fontWeight(.medium)
                    }
                    Link(destination: URL(string: aboutPage.linkedInUrl)!) {
                        Label("LinkedIn", image: "linkedin-fill")
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()

        }
        .navigationTitle("About")
        .task {
            viewModel.getAboutPage()
        }
    }
}

extension AboutScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var aboutPage: AboutPage?
        
        func getAboutPage() {
            Task {
                switch await repository.document.getAboutPage() {
                case let .success(aboutPage):
                    await MainActor.run {
                        print(aboutPage)
                        self.aboutPage = aboutPage
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
        
    }
}

struct AboutScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AboutScreenView()
    }
}
