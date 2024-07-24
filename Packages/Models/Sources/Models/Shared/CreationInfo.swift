import Foundation

public protocol CreationInfo {
    var createdBy: Profile.Saved { get }
    var createdAt: Date { get }
}
