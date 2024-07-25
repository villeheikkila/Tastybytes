import Foundation
public import Tagged

public enum Profile {}

public extension Profile {
    typealias Id = Tagged<Profile, UUID>
}

public protocol AvatarURL {
    var id: Profile.Id { get }
    var avatars: [ImageEntity.Saved] { get }
}

public extension ProfileProtocol {
    func getAvatarUrl(baseUrl: URL) -> URL? {
        guard let imageEntity = avatars.first else { return nil }
        return imageEntity.getLogoUrl(baseUrl: baseUrl)
    }
}

public protocol ProfileProtocol {
    var id: Profile.Id { get }
    var preferredName: String { get }
    var isPrivate: Bool { get }
    var joinedAt: Date { get }
    var avatars: [ImageEntity.Saved] { get }
}
