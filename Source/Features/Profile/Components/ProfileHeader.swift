import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct ProfileHeader: View {
    private let logger = Logger(category: "ProfileHeader")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @State private var profile: Profile
    @State private var profileSummary: ProfileSummary?
    @State private var alertError: AlertError?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoading = false
    @State private var loadImagesTask: Task<Void, Never>?
    @State private var page = 0
    @Binding var refreshId: Int
    @State private var resultId: Int?
    private let pageSize = 10

    private let isCurrentUser: Bool
    private let isShownInFull: Bool
    let topAnchor: Int

    init(profile: Profile, refreshId: Binding<Int>, isCurrentUser: Bool, topAnchor: Int) {
        _profile = State(wrappedValue: profile)
        self.isCurrentUser = isCurrentUser
        self.topAnchor = topAnchor
        _refreshId = refreshId
        isShownInFull = isCurrentUser || !profile.isPrivate
    }

    var showInFull: Bool {
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        EmptyView()
    }
}
