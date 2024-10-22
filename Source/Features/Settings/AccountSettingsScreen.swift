import Components

import Extensions
import Models
import Logging
import PhotosUI
import Repositories
import SwiftUI

struct AccountSettingsScreen: View {
    private let logger = Logger(label: "AccountSettingsScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AppModel.self) private var appModel
    @Environment(ProfileModel.self) private var profileModel
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
                showEmailConfirmation = email != profileModel.email
            }
        }
        .onAppear {
            email = profileModel.email
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: csvExport,
            contentType: UTType.commaSeparatedText,
            defaultFilename:
            "\(appModel.infoPlist.appName.lowercased())_export_\(Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))).csv"
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
                AsyncButton(
                    "account.email.sendVerificationLink.label",
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
                AsyncButton(
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
                    AsyncButton(
                        "account.delete.label",
                        role: .destructive,
                        action: {
                            await profileModel.deleteCurrentAccount()
                            profileDeleted = true
                        }
                    )
                }
            }
            .fontWeight(.medium)
        }
    }

    private func changeEmail(email: String) async {
        do {
            try await repository.auth.sendEmailVerification(email: email)
            router.open(.toast(.success("account.feedback.sent.toast")))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to change email. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func exportData() async {
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
