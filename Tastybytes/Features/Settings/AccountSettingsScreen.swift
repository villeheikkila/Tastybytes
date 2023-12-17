import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

private let logger = Logger(category: "AccountSettingsScreen")

struct AccountSettingsScreen: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var showDeleteConfirmation = false
    @State private var showEmailConfirmation = false
    @State private var showAccountDeleteScreen = false
    @State private var email = ""

    @State var csvExport: CSVFile? {
        didSet {
            showingExporter.toggle()
        }
    }

    @State var showingExporter = false
    @State private var alertError: AlertError?

    var body: some View {
        @Bindable var profileEnvironmentModel = profileEnvironmentModel
        Form {
            emailSection
            deleteAccount
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showAccountDeleteScreen, content: {
            AccountDeletedScreen()
        })
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
        .fileExporter(isPresented: $showingExporter,
                      document: csvExport,
                      contentType: UTType.commaSeparatedText,
                      defaultFilename: "\(Config.appName.lowercased())_export_\(Date().customFormat(.fileNameSuffix)).csv")
        { result in
            switch result {
            case .success:
                feedbackEnvironmentModel.toggle(.success("Data was exported as CSV"))
            case .failure:
                alertError = .init(title: "Error occurred while trying to export data")
            }
        }
        .alertError($alertError)
        .confirmationDialog(
            "Are you sure you want to permanently delete your account? All data will be lost.",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            ProgressButton(
                "Delete Account",
                role: .destructive,
                action: {
                    await profileEnvironmentModel.deleteCurrentAccount(onAccountDeletion: {
                        showAccountDeleteScreen = true
                    })
                }
            )
        }
    }

    private var emailSection: some View {
        Section {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if showEmailConfirmation {
                ProgressButton(
                    "Send Verification Link",
                    actionOptions: [],
                    action: {
                        await changeEmail()
                    }
                )
                .transition(.slide)
            }

        } header: {
            Text("Email")
        } footer: {
            Text("Email is only used for login and is not shown for other users.")
        }
        .headerProminence(.increased)
    }

    private var deleteAccount: some View {
        Section {
            Group {
                ProgressButton(
                    "Export CSV",
                    systemImage: "square.and.arrow.up",
                    action: { await exportData() }
                )
                Button(
                    "Delete Account",
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
            feedbackEnvironmentModel.toggle(.success("Sent!"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to change email. Error: \(error) (\(#file):\(#line))")
        }
    }

    func exportData() async {
        switch await repository.profile.currentUserExport() {
        case let .success(csvText):
            csvExport = CSVFile(initialText: csvText)
            showingExporter = true
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to export check-in csv. Error: \(error) (\(#file):\(#line))")
        }
    }
}
