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

    let profile: Profile
    let onDelete: (_ profile: Profile) -> Void

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("profile.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
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
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.profile(profile.id))))
            RouterLink("contributions.title", systemImage: "plus", open: .screen(.contributions(profile)))
            if profileEnvironmentModel.hasRole(.superAdmin) {
                RouterLink("profile.rolePickerSheet.navigationTitle", systemImage: "lock", open: .screen(.roleSuperAdminPicker(profile: profile)))
            }
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: profile,
                action: deleteProduct,
                description: "profile.delete.confirmation.description",
                label: "profile.delete.confirmation.label \(profile.preferredName)",
                isDisabled: !profileEnvironmentModel.hasRole(.superAdmin)
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func deleteProduct(_ profile: Profile) async {
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

struct RoleSuperAdminPickerScreen: View {
    let logger = Logger(category: "RoleSuperAdminPickerScreen")
    @Environment(Repository.self) private var repository
    @State private var availableRoles = [Role]()
    @State private var selectedRoles = [Role]()

    let profile: Profile

    var body: some View {
        List(availableRoles) { role in
            Section {
                ForEach(role.permissions) { permission in
                    HStack {
                        Text(permission.name)
                        Spacer()
                    }
                }
            } header: {
                HStack {
                    Text(role.name)
                    Spacer()
                    Label("settings.appIcon.selected", systemImage: "checkmark")
                        .labelStyle(.iconOnly)
                        .opacity(selectedRoles.contains(role) ? 1 : 0)
                }
            }
        }
        .animation(.default, value: availableRoles)
        .navigationTitle("profile.rolePickerSheet.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func load() async {
        async let availableRolesPromise = repository.profile.getRoles()
        //async let profileRolesPromise = repository.profile.getRolesForProfile(id: profile.id)

        do {
            let (availableRoles) = try await (availableRolesPromise)
            self.availableRoles = availableRoles
           // self.selectedRoles = selectedRoles
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }
}
