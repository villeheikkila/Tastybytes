import Components

import Logging
import Models
import Repositories
import SwiftUI

struct RoleSuperAdminPickerScreen: View {
    let logger = Logger(label: "RoleSuperAdminPickerScreen")
    @Environment(AdminModel.self) private var adminModel
    @Environment(Repository.self) private var repository

    @Binding var profile: Profile.Detailed
    let roles: [Role.Joined]

    var body: some View {
        List(adminModel.roles) { role in
            RolePickerRowView(profile: $profile, role: role)
        }
        .animation(.default, value: adminModel.roles)
        .navigationTitle("profile.rolePickerSheet.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RolePickerRowView: View {
    let logger = Logger(label: "RolePickerRowView")
    @Environment(Repository.self) private var repository
    @State private var showConfirmationDialogForAddingPermission = false
    @State private var showConfirmationDialogForRemovingPermission = false
    @Binding var profile: Profile.Detailed

    let role: Role.Joined

    private var isSelected: Bool {
        profile.roles.map(\.id).contains(role.id)
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
            .disabled(role.name == Role.Name.superAdmin.rawValue)
        }
        .confirmationDialog(
            "Are you sure you want to remove \(role.label) role from \(profile.preferredName)",
            isPresented: $showConfirmationDialogForRemovingPermission,
            titleVisibility: .visible,
            presenting: role
        ) { presenting in
            AsyncButton("labels.ok", action: {
                await removeRoleFromProfile(presenting)
            })
        }
        .confirmationDialog(
            "Are you sure you want to give \(profile.preferredName) the \(role.label). Giving user access to destructive features can be dangerous",
            isPresented: $showConfirmationDialogForAddingPermission,
            titleVisibility: .visible,
            presenting: role
        ) { presenting in
            AsyncButton("labels.ok", role: .destructive, action: {
                await addRoleForProfile(presenting)
            })
        }
    }

    private func removeRoleFromProfile(_ role: Role.Joined) async {
        do {
            try await repository.role.removeRoleFromProfile(profile: profile.profile, role: role)
            profile = profile.copyWith(roles: profile.roles.removing(role))
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func addRoleForProfile(_ role: Role.Joined) async {
        do {
            try await repository.role.addRoleForProfile(profile: profile.profile, role: role)
            profile = profile.copyWith(roles: profile.roles + [role])
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to load roles. Error: \(error) (\(#file):\(#line))")
        }
    }
}
