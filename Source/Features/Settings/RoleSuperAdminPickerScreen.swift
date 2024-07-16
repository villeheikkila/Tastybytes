import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct RoleSuperAdminPickerScreen: View {
    let logger = Logger(category: "RoleSuperAdminPickerScreen")
    @Environment(Repository.self) private var repository
    @State private var availableRoles = [Role]()

    @Binding var profile: Profile.Detailed?
    let roles: [Role]

    var body: some View {
        List(availableRoles) { role in
            RolePickerRowView(profile: $profile, role: role)
        }
        .animation(.default, value: availableRoles)
        .navigationTitle("profile.rolePickerSheet.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func load() async {
        do {
            availableRoles = try await repository.role.getRoles()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct RolePickerRowView: View {
    let logger = Logger(category: "RolePickerRowView")
    @Environment(Repository.self) private var repository
    @State private var showConfirmationDialogForAddingPermission = false
    @State private var showConfirmationDialogForRemovingPermission = false
    @Binding var profile: Profile.Detailed?

    let role: Role

    private var isSelected: Bool {
        profile?.roles.map(\.id).contains(role.id) ?? false
    }

    var body: some View {
        Section {
            ForEach(role.permissions) { permission in
                HStack {
                    Text(permission.label)
                    Spacer()
                }
            }
        } header: {
            Button(action: {
                if isSelected {
                    showConfirmationDialogForRemovingPermission = true
                } else {
                    showConfirmationDialogForAddingPermission = true
                }
            }) {
                HStack {
                    Text(role.label)
                    Spacer()
                    Label("settings.appIcon.selected", systemImage: "checkmark")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.green)
                        .opacity(isSelected ? 1 : 0)
                }
            }
            .disabled(role.name == RoleName.superAdmin.rawValue)
        }
        .confirmationDialog(
            "Are you sure you want to remove \(role.label) role from \(profile?.preferredName ?? "-")",
            isPresented: $showConfirmationDialogForRemovingPermission,
            titleVisibility: .visible,
            presenting: role
        ) { presenting in
            AsyncButton("labels.ok", action: {
                await removeRoleFromProfile(presenting)
            })
        }
        .confirmationDialog(
            "Are you sure you want to give \(profile?.preferredName ?? "-") the \(role.label). Giving user access to destructive features can be dangerous",
            isPresented: $showConfirmationDialogForAddingPermission,
            titleVisibility: .visible,
            presenting: role
        ) { presenting in
            AsyncButton("labels.ok", role: .destructive, action: {
                await addRoleForProfile(presenting)
            })
        }
    }

    private func removeRoleFromProfile(_ role: Role) async {
        guard let profile else { return }
        do {
            try await repository.role.removeProfileFromProfile(profile: profile.profile, role: role)
            self.profile = profile.copyWith(roles: profile.roles.removing(role))
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func addRoleForProfile(_ role: Role) async {
        guard let profile else { return }
        do {
            try await repository.role.addProfileForProfile(profile: profile.profile, role: role)
            self.profile = profile.copyWith(roles: profile.roles + [role])
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }
}
