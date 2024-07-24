import Foundation
public import Tagged

public enum CheckIn {}

public extension CheckIn {
    typealias Id = Tagged<CheckIn, Int>
}
