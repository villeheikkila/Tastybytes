import Foundation
public import Tagged

public enum Friend {}

public extension Friend {
    typealias Id = Tagged<Friend, Int>
}
