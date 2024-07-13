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
    @AppStorage(.profileDeleted) private var profileDeleted = false
    @State private var showDeleteConfirmation = false
    @State private var showEmailConfirmation = false
    @State private var email = ""
    @State private var csvExport: CSVFile?
    @State private var showingExporter = false

    var body: some View {
        Form {
            emailSection
            deleteAccount
        }
        .navigationTitle("account.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
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
                router.open(.toast(.success("account.export.success.toast")))
            case .failure:
                router.open(.alert(.init(title: "account.export.failure.alert")))
            }
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
                        await changeEmail(email: email)
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
                )
                .foregroundColor(.red)
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
            .fontWeight(.medium)
        }
    }

    func changeEmail(email: String) async {
        do {
            try await repository.auth.sendEmailVerification(email: email)
            router.open(.toast(.success("account.feedback.sent.toast")))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to change email. Error: \(error) (\(#file):\(#line))")
        }
    }

    func exportData() async {
        do {
            let csvText = try await repository.profile.currentUserExport()
            csvExport = CSVFile(content: csvText)
            showingExporter = true
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to export check-in csv. Error: \(error) (\(#file):\(#line))")
        }
    }
}
