
import Models
import Repositories
import SwiftUI

struct ProfilesAdminScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackModel.self) private var feedbackModel
    @State private var state: ScreenState = .loading
    @State private var profiles = [Profile.Saved]()
    @State private var searchTerm = ""

    private var filteredProfiles: [Profile.Saved] {
        profiles.filteredBySearchTerm(by: \.preferredName, searchTerm: searchTerm)
    }

    var body: some View {
        List(filteredProfiles) { profile in
            RouterLink(open: .screen(.profile(profile))) {
                ProfileEntityView(profile: profile)
            }
            .swipeActions {
                Button("profile.admin.navigationTitle", systemImage: "wrench.and.screwdriver") {
                    router.open(.sheet(.profileAdmin(id: profile.id, onDelete: { profile in
                        profiles = profiles.removingWithId(profile.id)
                    })))
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm)
        .animation(.default, value: profiles)
        .navigationTitle("admin.profiles.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func load() async {
        do {
            let profiles = try await repository.profile.getAll()
            self.profiles = profiles
            state = .populated
        } catch {
            state = .getState(error: error, withHaptics: false, feedbackModel: feedbackModel)
        }
    }
}
