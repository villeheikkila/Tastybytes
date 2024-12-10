import Foundation
public import Tagged

public enum Logo {}

public extension Logo {
    typealias Id = Tagged<Logo, UUID>
}
