import SwiftUI

struct AboutScreen: View {
  private let logger = getLogger(category: "AboutScreen")
  @EnvironmentObject private var client: AppClient
  @State private var aboutPage: AboutPage?

  var body: some View {
    VStack {
      List {
        header.listRowBackground(Color.clear)
        aboutSection
        footer
      }
    }
    .navigationTitle("About")
    .task {
      await getAboutPage()
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

  @ViewBuilder var aboutSection: some View {
    if let aboutPage {
      Section {
        Text(aboutPage.summary)
      }

      Section {
        if let githubUrl = URL(string: aboutPage.githubUrl) {
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
        if let portfolioUrl = URL(string: aboutPage.portfolioUrl) {
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
        if let linkedInUrl = URL(string: aboutPage.linkedInUrl) {
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
        Label("Copyright", systemImage: "c.circle")
          .labelStyle(.iconOnly)
          .font(.caption).bold()

        if let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year {
          Text(String(currentYear))
            .font(.caption).bold()
        }
        Text("Ville Heikkilä")
          .font(.caption).bold()
      }
    }
  }

  func getAboutPage() async {
    switch await client.document.getAboutPage() {
    case let .success(aboutPage):
      self.aboutPage = aboutPage
    case let .failure(error):
      logger.error("fetching about page failed: \(error.localizedDescription)")
    }
  }
}
