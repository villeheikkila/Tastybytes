import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileAdminSheet: View {
    let logger = Logger(category: "ProfileAdminSheet")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Repository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var detailedProfile: Profile.Detailed?
    @State private var summary: ProfileSummary?

    let profile: Profile
    let onDelete: (_ profile: Profile) -> Void

    private var isProfileDeletable: Bool {
        if let summary {
            profileEnvironmentModel.hasRole(.superAdmin) && summary.totalCheckIns > 0
        } else {
            false
        }
    }

    var body: some View {
        Form {
            if state == .populated, let detailedProfile, let summary {
                content(detailedProfile, summary)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("profile.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await load()
        }
    }

    @ViewBuilder private func content(_ detailedProfile: Profile.Detailed, _ summary: ProfileSummary) -> some View {
        Section("profile.admin.section.profile") {
            RouterLink(open: .screen(.profile(profile))) {
                ProfileEntityView(profile: profile)
            }
        }
        .customListRowBackground()
        Section("admin.section.details") {
            LabeledIdView(id: profile.id.uuidString)
            LabeledContent("profile.admin.joinedAt.label", value: profile.joinedAt.formatted(.dateTime
                    .year()
                    .month(.wide)
                    .day()))
            LabeledContent("settings.profile.username", value: detailedProfile.username ?? "-")
            LabeledContent("settings.profile.firstName", value: detailedProfile.firstName ?? "-")
            LabeledContent("settings.profile.lastName", value: detailedProfile.lastName ?? "-")
            LabeledContent("profile.admin.avatars.count", value: detailedProfile.avatars.count.formatted())
            Toggle("profile.admin.isOnboarded", isOn: .init(get: {
                detailedProfile.isOnboarded
            }, set: { _ in }))
                .disabled(true)
            LabeledContent("profile.uniqueCheckIns", value: summary.uniqueCheckIns.formatted())
            LabeledContent("profile.totalCheckIns", value: summary.totalCheckIns.formatted())
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.profile(profile.id))))
            RouterLink("contributions.title", systemImage: "plus", open: .screen(.contributions(profile)))
            if profileEnvironmentModel.hasRole(.superAdmin) {
                RouterLink(
                    "profile.rolePickerSheet.navigationTitle",
                    systemImage: "lock",
                    open: .screen(.roleSuperAdminPicker(profile: $detailedProfile, roles: detailedProfile.roles))
                )
            }
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: profile,
                action: delete,
                description: "profile.delete.confirmation.description",
                label: "profile.delete.confirmation.label \(profile.preferredName)",
                isDisabled: isProfileDeletable
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func load() async {
        do {
            detailedProfile = try await repository.profile.getDetailed(id: profile.id)
            summary = try await repository.checkIn.getSummaryByProfileId(id: profile.id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to delete profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func delete(_ profile: Profile) async {
        do {
            try await repository.profile.deleteUserAsSuperAdmin(profile)
            onDelete(profile)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete profile. Error: \(error) (\(#file):\(#line))")
        }
    }
}
