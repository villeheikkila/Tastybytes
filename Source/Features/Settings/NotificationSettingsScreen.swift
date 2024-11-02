
import Models
import SwiftUI

struct NotificationSettingsScreen: View {
    var body: some View {
        Form {
            NotificationDeliveryMethodSection()
            if let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) {
                Section {
                    Link("notitifications.systemSettings.link", destination: settingsUrl)
                } header: {
                    Text("notitifications.systemSettings.title")
                } footer: {
                    Text("notitifications.systemSettings.description")
                }
            }
        }
        .navigationTitle("settings.notifications.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationDeliveryMethodSection: View {
    @Environment(ProfileModel.self) private var profileModel
    @State private var notificationSettings: [NotificationType: Models.Notification.DeliveryType] = [:]
    @State private var task: Task<Void, Never>?

    var body: some View {
        Section {
            ForEach(NotificationType.allCases) { type in
                NotificationDeliveryTypePickerView(
                    notificationDeliveryType: .init(
                        get: {
                            profileModel.notificationSettings[keyPath: type.keyPath]
                        },
                        set: { newValue in
                            updateNotificationSetting(for: type, with: newValue)
                        }
                    ),
                    title: type.title,
                    subtitle: type.subtitle
                )
                .disabled(task != nil)
            }
        }
    }

    func updateNotificationSetting(for type: NotificationType, with newValue: Models.Notification.DeliveryType) {
        defer { task = nil }
        task = Task {
            switch type {
            case .reaction:
                await profileModel.updatePushNotificationSettingsForDevice(reactions: newValue)
            case .comment:
                await profileModel.updatePushNotificationSettingsForDevice(checkInComment: newValue)
            case .checkIn:
                await profileModel.updatePushNotificationSettingsForDevice(taggedCheckIn: newValue)
            case .friendRequest:
                await profileModel.updatePushNotificationSettingsForDevice(friendRequest: newValue)
            }
        }
    }
}

struct NotificationDeliveryTypePickerView: View {
    @Binding var notificationDeliveryType: Models.Notification.DeliveryType
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?

    var body: some View {
        Picker(selection: $notificationDeliveryType) {
            ForEach(Models.Notification.DeliveryType.allCases) { deliveryType in
                Text(deliveryType.label).tag(deliveryType)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .pickerStyle(.navigationLink)
    }
}

enum NotificationType: String, CaseIterable, Identifiable {
    case reaction, comment, checkIn, friendRequest

    var id: String {
        rawValue
    }

    var title: LocalizedStringKey {
        switch self {
        case .reaction: "notifications.settings.reactions.label"
        case .comment: "notifications.settings.comments.label"
        case .checkIn: "notifications.settings.checkIns.label"
        case .friendRequest: "notifications.settings.friendRequest.label"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .reaction: "notifications.settings.reactions.subtitle"
        case .comment: "notifications.settings.comments.subtitle"
        case .checkIn: "notifications.settings.checkIns.subtitle"
        case .friendRequest: "notifications.settings.friendRequest.subtitle"
        }
    }

    var keyPath: KeyPath<Models.Notification.Settings, Models.Notification.DeliveryType> {
        switch self {
        case .reaction:
            \.reactions
        case .comment:
            \.checkInComment
        case .checkIn:
            \.taggedCheckIn
        case .friendRequest:
            \.friendRequest
        }
    }
}

extension Models.Notification.DeliveryType {
    var label: LocalizedStringKey {
        switch self {
        case .disabled:
            "notification.deliveryType.disabled"
        case .inApp:
            "notification.deliveryType.disabled.inApp"
        case .pushNotification:
            "notification.deliveryType.push"
        }
    }
}
