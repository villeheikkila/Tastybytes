import Foundation

public protocol CreationInfoCascade {
    var createdBy: Profile.Saved { get }
    var createdAt: Date { get }
}

public protocol CreationInfo {
    var createdBy: Profile.Saved? { get }
    var createdAt: Date { get }
}
