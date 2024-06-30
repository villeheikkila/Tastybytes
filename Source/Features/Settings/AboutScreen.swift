import Components
import EnvironmentModels
import Extensions
import MessageUI
import Models
import OSLog
import StoreKit
import SwiftUI

@MainActor
struct AboutScreen: View {
    private let logger = Logger(category: "AboutScreen")
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    // @Environment(\.requestReview) var requestReview
    @State private var email: Email = .init()

    var body: some View {
        List {
            header
            support
            aboutSection
            footer
        }
        .foregroundColor(.primary)
        .listStyle(.insetGrouped)
        .navigationTitle("about.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            email = Email(adress: appEnvironmentModel.config.feedbackEmail,
                          subject: "Feedback for \(appEnvironmentModel.infoPlist.appName)",
                          body: "")
        }
    }

    var header: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    AppLogoView()
                        .frame(width: 80, height: 80)
                    AppNameView()
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder var support: some View {
        RouterLink(
            "about.sendFeedback.label",
            systemName: "envelope",
            color: .green,
            sheet: .sendEmail(email: $email, callback: { result in
                switch result {
                case let .success(successResult) where successResult == MFMailComposeResult.sent:
                    feedbackEnvironmentModel.toggle(.success("about.sendFeedback.success.toast"))
                case .failure:
                    router.openAlert(.init())
                default:
                    return
                }
            })
        )
        ProgressButton("about.rateApp.label \(appEnvironmentModel.infoPlist.appName)", systemName: "heart", color: .red, action: {
           // requestReview()
        })
    }

    @ViewBuilder var aboutSection: some View {
        if let aboutPage = appEnvironmentModel.aboutPage {
            Section {
                Text(aboutPage.summary)
            }

            Section {
                if let githubUrl = URL(string: aboutPage.githubUrl) {
                    Link(destination: githubUrl) {
                        HStack {
                            Image(.github)
                                .accessibilityHidden(true)
                                .frame(width: 18, height: 18)
                                .padding(.leading, 5)
                                .padding(.trailing, 15)

                            Text("links.gitHub")
                                .fontWeight(.medium)
                        }
                    }
                }
                if let portfolioUrl = URL(string: aboutPage.portfolioUrl) {
                    Link(destination: portfolioUrl) {
                        HStack {
                            Image(systemName: "network")
                                .accessibilityHidden(true)
                                .frame(width: 18, height: 18)
                                .padding(.leading, 5)
                                .padding(.trailing, 15)

                            Text("links.portfolio")
                                .fontWeight(.medium)
                        }
                    }
                }
                if let linkedInUrl = URL(string: aboutPage.linkedInUrl) {
                    Link(destination: linkedInUrl) {
                        HStack {
                            Image(.linkedin)
                                .accessibilityHidden(true)
                                .frame(width: 18, height: 18)
                                .padding(.leading, 5)
                                .padding(.trailing, 15)

                            Text("links.linkedIn")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder var footer: some View {
        Section {
            VStack {
                Text("\(appEnvironmentModel.infoPlist.appName) \(appEnvironmentModel.infoPlist.appVersion.prettyString) (\(appEnvironmentModel.infoPlist.bundleVersion))")
                    .font(.caption).bold()
                HStack {
                    Spacer()
                    HStack(alignment: .center, spacing: 2) {
                        Label("labels.copyright", systemImage: "c.circle")
                            .labelStyle(.iconOnly)
                        if let appConfig = appEnvironmentModel.appConfig {
                            Text("\(appConfig.copyrightTimeRange) \(appConfig.copyrightHolder)")
                        }
                    }
                    .font(.caption).bold()
                    Spacer()
                }
            }
        }.listRowBackground(Color.clear)
    }
}
