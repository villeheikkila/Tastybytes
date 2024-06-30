import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct AccountSettingsScreen: View {
    private let logger = Logger(category: "AccountSettingsScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @AppStorage(.profileDeleted) private var profileDeleted = false
    @State private var showDeleteConfirmation = false
    @State private var showEmailConfirmation = false
    @State private var showAccountDeleteScreen = false
    @State private var email = ""
    @State private var csvExport: CSVFile?
    @State private var showingExporter = false

    var body: some View {
        @Bindable var profileEnvironmentModel = profileEnvironmentModel
        Form {
            emailSection
            deleteAccount
        }
        .navigationTitle("account.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(
            isPresented: $showAccountDeleteScreen,
            content: {
                AccountDeletedScreen()
            }
        )
        .transaction { transaction in
            if showAccountDeleteScreen {
                transaction.disablesAnimations = true
            }
        }
        .onChange(of: email) {
            withAnimation {
                showEmailConfirmation = email != profileEnvironmentModel.email
            }
        }
        .onAppear {
            email = profileEnvironmentModel.email
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: csvExport,
            contentType: UTType.commaSeparatedText,
            defaultFilename:
            "\(appEnvironmentModel.infoPlist.appName.lowercased())_export_\(Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))).csv"
        ) { result in
            switch result {
            case .success:
                feedbackEnvironmentModel.toggle(.success("account.export.success.toast"))
            case .failure:
                router.openAlert(.init(title: "account.export.failure.alert"))
            }
        }
        .confirmationDialog(
            "account.delete.confirmationDialog.title",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            ProgressButton(
                "account.delete.label",
                role: .destructive,
                action: {
                    await profileEnvironmentModel.deleteCurrentAccount()
                    profileDeleted = true
                }
            )
        }
    }

    private var emailSection: some View {
        Section {
            TextField("account.email.placeholder", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if showEmailConfirmation {
                ProgressButton(
                    "account.email.sendVerificationLink.label",
                    actionOptions: [],
                    action: {
                        await changeEmail()
                    }
                )
                .transition(.slide)
            }

        } header: {
            Text("account.email.section.title")
        } footer: {
            Text("account.email.section.footer")
        }
        .headerProminence(.increased)
    }

    private var deleteAccount: some View {
        Section {
            Group {
                ProgressButton(
                    "account.export.label",
                    systemImage: "square.and.arrow.up",
                    action: { await exportData() }
                )
                Button(
                    "account.delete.label",
                    systemImage: "person.crop.circle.badge.minus",
                    role: .destructive,
                    action: { showDeleteConfirmation = true }
                ).foregroundColor(.red)
            }.fontWeight(.medium)
        }
    }

    func changeEmail() async {
        switch await repository.auth.sendEmailVerification(email: email) {
        case .success:
            feedbackEnvironmentModel.toggle(.success("account.feedback.sent.toast"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Failed to change email. Error: \(error) (\(#file):\(#line))")
        }
    }

    func exportData() async {
        switch await repository.profile.currentUserExport() {
        case let .success(csvText):
            csvExport = CSVFile(content: csvText)
            showingExporter = true
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.openAlert(.init())
            logger.error("Failed to export check-in csv. Error: \(error) (\(#file):\(#line))")
        }
    }
}
