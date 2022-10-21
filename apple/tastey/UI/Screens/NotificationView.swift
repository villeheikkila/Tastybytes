import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var currentProfile: CurrentProfile
    
    var body: some View {
        ScrollView {
            Text("Notifications")
                .font(.headline)
            VStack {
                ForEach(currentProfile.notifications) {
                        notification in
                        HStack{
                            Text(notification.message)
                            Spacer()
                            Button(action: {
                                currentProfile.deleteNotifications(notification: notification)
                            }) {
                                Image(systemName: "xmark.app")
                                    .imageScale(.large)
                            }
                        }
                        .padding(.all, 12)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                        .padding([.leading, .trailing], 10)
                    }
                }
            }
    }
}

