import EnvironmentModels
import SwiftUI

struct PermissionOnboarding: View {
    @Binding var currentTab: OnboardingScreen.Tab
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel

    var pushNotificationButtonTitle: String {
        switch permissionEnvironmentModel.pushNotificationStatus {
        case .authorized, .provisional:
            return "Allowed"
        case .denied:
            return "Denied"
        default:
            return "Allow"
        }
    }

    var photoLibraryButtonTitle: String {
        switch permissionEnvironmentModel.photoLibraryStatus {
        case .authorized:
            return "Allowed"
        case .denied:
            return "Denied"
        default:
            return "Allow"
        }
    }

    var cameraButtonTitle: String {
        switch permissionEnvironmentModel.cameraStatus {
        case .authorized:
            return "Allowed"
        case .denied:
            return "Denied"
        default:
            return "Allow"
        }
    }

    var locationButtonTitle: String {
        switch permissionEnvironmentModel.locationsStatus {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return "Allowed"
        case .denied:
            return "Denied"
        default:
            return "Allow"
        }
    }

    var body: some View {
        List {
            Text("Permissions")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()

            PermissionListRow(
                title: "Notification",
                subtitle: "Notifications for reactions, tags and comments",
                buttonTitle: pushNotificationButtonTitle,
                systemName: "bell.fill",
                action: {
                    permissionEnvironmentModel.requestPushNotificationAuthorization()
                }
            )
            PermissionListRow(
                title: "Photo Library",
                subtitle: "Add photos to your check-ins",
                buttonTitle: photoLibraryButtonTitle,
                systemName: "photo",
                action: {
                    permissionEnvironmentModel.requestPhotoLibraryAuthorization()
                }
            )
            PermissionListRow(
                title: "Camera",
                subtitle: "Take photos for your check-ins",
                buttonTitle: cameraButtonTitle,
                systemName: "camera",
                action: {
                    permissionEnvironmentModel.requestCameraAuthorization()
                }
            )
            PermissionListRow(
                title: "Location",
                subtitle: "Find nearby locations for your check-ins",
                buttonTitle: locationButtonTitle,
                systemName: "location.fill.viewfinder",
                action: {
                    permissionEnvironmentModel.requestLocationAuthorization()
                }
            )
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .simultaneousGesture(DragGesture())
        .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
            if let nextTab = currentTab.next {
                withAnimation {
                    currentTab = nextTab
                }
            }
        }))
    }
}

private struct PermissionListRow: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let systemName: String
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.blue)
                .frame(width: 36, height: 36, alignment: .center)
                .accessibility(hidden: true)
                .padding()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
                HStack {
                    Text(subtitle)
                        .font(.caption)
                        .lineLimit(nil)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            Button(buttonTitle, action: action)
                .foregroundColor(.white)
                .font(.body)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(20)
                .padding(.leading, 4)
        }
        .listRowInsets(EdgeInsets(top: 32, leading: 24, bottom: 8, trailing: 24))
        .listRowSeparator(.hidden)
    }
}
