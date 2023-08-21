import EnvironmentModels
import MessageUI
import OSLog
import StoreKit
import SwiftUI

private let logger = Logger(category: "AboutScreen")

struct AboutScreen: View {
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.requestReview) var requestReview
    @State private var email = Email.feedback

    var body: some View {
        List {
            header
            support
            aboutSection
            footer
        }
        .foregroundColor(.primary)
        .listStyle(.insetGrouped)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    var header: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    AppLogoView(size: 80)
                    AppNameView()
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder var support: some View {
        RouterLink(
            "Send Feedback",
            systemSymbol: .envelope,
            color: .green,
            sheet: .sendEmail(email: $email, callback: { result in
                switch result {
                case let .success(successResult) where successResult == MFMailComposeResult.sent:
                    feedbackEnvironmentModel.toggle(.success("Thanks for the feedback!"))
                case .failure:
                    feedbackEnvironmentModel.toggle(.error(.unexpected))
                default:
                    return
                }
            })
        )
        ProgressButton("Rate \(Config.appName)", systemSymbol: .heart, color: .red, action: {
            await requestReview()
        })
    }

    @ViewBuilder var aboutSection: some View {
        if let aboutPage = appDataEnvironmentModel.aboutPage {
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

    @ViewBuilder var footer: some View {
        Section {
            HStack {
                Spacer()
                HStack(alignment: .center) {
                    Label("Copyright", systemSymbol: .cCircle)
                        .labelStyle(.iconOnly)
                        .font(.caption).bold()

                    if let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year {
                        Text("2019-\(String(currentYear))")
                            .font(.caption).bold()
                    }
                    Text("Ville Heikkilä")
                        .font(.caption).bold()
                }
                Spacer()
            }
        }.listRowBackground(Color.clear)
    }
}
