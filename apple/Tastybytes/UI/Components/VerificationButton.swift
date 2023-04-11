import SwiftUI

struct VerificationButton: View {
  @EnvironmentObject private var profileManager: ProfileManager
  let isVerified: Bool
  let onClick: () async -> Void

  var label: String { isVerified ? "Verified" : "Unverified" }
  var systemImage: String { isVerified ? "checkmark.circle" : "x.circle" }

  var body: some View {
    if profileManager.hasPermission(.canVerify) {
      ProgressButton(action: { await onClick() }, label: {
        Label(label, systemImage: systemImage)
      })
    } else {
      Label(label, systemImage: systemImage)
    }
  }
}
