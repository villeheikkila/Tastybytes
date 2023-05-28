import SwiftUI

struct PermissionOnboarding: View {
  @Binding var currentTab: OnboardingScreen.Tab
  @EnvironmentObject private var permissionManager: PermissionManager

  var pushNotificationButtonTitle: String {
    switch permissionManager.pushNotificationStatus {
    case .authorized, .provisional:
      return "Allowed"
    case .denied:
      return "Denied"
    default:
      return "Allow"
    }
  }

  var photoLibraryButtonTitle: String {
    switch permissionManager.photoLibraryStatus {
    case .authorized:
      return "Allowed"
    case .denied:
      return "Denied"
    default:
      return "Allow"
    }
  }

  var cameraButtonTitle: String {
    switch permissionManager.cameraStatus {
    case .authorized:
      return "Allowed"
    case .denied:
      return "Denied"
    default:
      return "Allow"
    }
  }

  var locationButtonTitle: String {
    switch permissionManager.locationsStatus {
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

      PermissionListRow(
        title: "Notification",
        subtitle: "Notifications for reactions, tags and comments",
        buttonTitle: pushNotificationButtonTitle,
        systemName: "bell.fill",
        action: {
          permissionManager.requestPushNotificationAuthorization()
        }
      )
      PermissionListRow(
        title: "Photo Library",
        subtitle: "Add photos to your check-ins",
        buttonTitle: photoLibraryButtonTitle,
        systemName: "photo",
        action: {
          permissionManager.requestPhotoLibraryAuthorization()
        }
      )
      PermissionListRow(
        title: "Camera",
        subtitle: "Take photos for your check-ins",
        buttonTitle: cameraButtonTitle,
        systemName: "camera",
        action: {
          permissionManager.requestCameraAuthorization()
        }
      )
      PermissionListRow(
        title: "Location",
        subtitle: "Find nearby locations for your check-ins",
        buttonTitle: locationButtonTitle,
        systemName: "location.fill.viewfinder",
        action: {
          permissionManager.requestLocationAuthorization()
        }
      )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .scrollDisabled(true)
    .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
      if let nextTab = currentTab.next {
        withAnimation {
          currentTab = nextTab
        }
      }
    }))
    .task {
      permissionManager.initialize()
    }
  }
}

struct PushNotificationOnboarding_Previews: PreviewProvider {
  static var previews: some View {
    TabView {
      PermissionOnboarding(currentTab: .constant(OnboardingScreen.Tab.pushNotification))
    }
  }
}

private struct PermissionListRow: View {
  let title: String
  let subtitle: String
  let buttonTitle: String
  let systemName: String
  let action: () -> Void

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: systemName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(Color.blue)
        .frame(width: 40, height: 40, alignment: .center)
        .accessibility(hidden: true)

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(title)
            .font(.title3)
            .fontWeight(.semibold)
          Spacer()
        }
        HStack {
          Text(subtitle)
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
    }
    .listRowInsets(EdgeInsets(top: 32, leading: 24, bottom: 8, trailing: 24))
    .listRowSeparator(.hidden)
  }
}