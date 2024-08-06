import Components

import Extensions
import MessageUI
import Models
import OSLog
import StoreKit
import SwiftUI

struct AboutScreen: View {
    private let logger = Logger(category: "AboutScreen")
    @Environment(AppModel.self) private var appModel
    @Environment(Router.self) private var router
    @Environment(\.requestReview) private var requestReview
    @State private var email: Email = .init()

    var body: some View {
        List {
            header
            about
            support
            policy
            footer
        }
        .foregroundColor(.primary)
        .listStyle(.insetGrouped)
        .navigationTitle("about.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            email = Email(adress: appModel.config.feedbackEmail,
                          subject: "Feedback for \(appModel.infoPlist.appName)",
                          body: "")
        }
    }

    private var header: some View {
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

    @ViewBuilder private var support: some View {
        RouterLink(
            "about.sendFeedback.label",
            systemName: "envelope",
            color: .green,
            open: .sheet(.sendEmail(email: $email, callback: { result in
                switch result {
                case let .success(successResult) where successResult == MFMailComposeResult.sent:
                    router.open(.toast(.success("about.sendFeedback.success.toast")))
                case .failure:
                    router.open(.alert(.init()))
                default:
                    return
                }
            }))
        )
        AsyncButton("about.rateApp.label \(appModel.infoPlist.appName)", systemName: "heart", color: .red, action: {
            requestReview()
        })
    }

    @ViewBuilder private var policy: some View {
        Section {
            RouterLink("privacyPolicy.link.label", systemName: "lock.shield", color: .blue, open: .screen(.privacyPolicy))
            RouterLink("termsOfService.link.label", systemName: "doc.text", color: .gray, open: .screen(.termsOfService))
            RouterLink(
                "includedLibraries.link.label",
                systemName: "square.stack.3d.up.fill",
                color: .indigo,
                open: .screen(.includedLibraries)
            )
        }
    }

    @ViewBuilder private var about: some View {
        if let aboutPage = appModel.aboutPage {
            Section {
                Text(aboutPage.summary)
                if let portfolioUrl = URL(string: aboutPage.portfolioUrl) {
                    Link(destination: portfolioUrl) {
                        Label("links.portfolio", systemImage: "network")
                    }
                }
            }
        }
    }

    @ViewBuilder private var footer: some View {
        Section {
            VStack {
                Text("\(appModel.infoPlist.appName) \(appModel.infoPlist.appVersion.prettyString) (\(appModel.infoPlist.bundleVersion))")
                    .font(.caption).bold()
                HStack {
                    Spacer()
                    HStack(alignment: .center, spacing: 2) {
                        Label("labels.copyright", systemImage: "c.circle")
                            .labelStyle(.iconOnly)
                        if let appConfig = appModel.appConfig {
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
