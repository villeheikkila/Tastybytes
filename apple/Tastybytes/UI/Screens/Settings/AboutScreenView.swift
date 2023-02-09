import SwiftUI

struct AboutScreenView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    VStack {
      List {
        header
          .listRowBackground(Color.clear)
        aboutSection
        footer
      }
    }
    .navigationTitle("About")
    .task {
      viewModel.getAboutPage()
    }
  }

  var header: some View {
    Section {
      HStack {
        Spacer()
        VStack(spacing: 10) {
          AppLogoView()
          AppNameView()
        }
        Spacer()
      }
    }
  }

  @ViewBuilder
  var aboutSection: some View {
    if let aboutPage = viewModel.aboutPage {
      Section {
        Text(aboutPage.summary)
      }

      Section {
        if let githubUrl = aboutPage.githubUrl, let githubUrl = URL(string: githubUrl) {
          Link(destination: githubUrl) {
            HStack {
              GitHubShape()
                .frame(width: 18, height: 18)
                .padding(.leading, 5)
                .padding(.trailing, 15)

              Text("GitHub")
                .fontWeight(.medium)
            }
          }
        }
        if let portfolioUrl = aboutPage.portfolioUrl, let portfolioUrl = URL(string: portfolioUrl) {
          Link(destination: portfolioUrl) {
            HStack {
              WebShape()
                .frame(width: 18, height: 18)
                .padding(.leading, 5)
                .padding(.trailing, 15)

              Text("Portfolio")
                .fontWeight(.medium)
            }
          }
        }
        if let linkedInUrl = aboutPage.linkedInUrl, let linkedInUrl = URL(string: linkedInUrl) {
          Link(destination: linkedInUrl) {
            HStack {
              LinkedInShape()
                .frame(width: 18, height: 18)
                .padding(.leading, 5)
                .padding(.trailing, 15)

              Text("LinkedIn")
                .fontWeight(.medium)
            }
          }
        }
      }
    }
  }

  var footer: some View {
    Section {
      HStack(alignment: .center) {
        Image(systemName: "c.circle")
          .font(.system(size: 12, weight: .bold, design: .default))

        if let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year {
          Text(String(currentYear))
            .font(.system(size: 12, weight: .bold, design: .default))
        }
        Text("Ville Heikkilä")
          .font(.system(size: 12, weight: .bold, design: .default))
      }
    }
  }
}

extension AboutScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "AboutScreenView")
    let client: Client
    @Published var aboutPage: AboutPage?

    init(_ client: Client) {
      self.client = client
    }

    func getAboutPage() {
      Task {
        switch await client.document.getAboutPage() {
        case let .success(aboutPage):
          self.aboutPage = aboutPage
        case let .failure(error):
          logger
            .error(
              "fetching about page failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
