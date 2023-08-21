import Models
import OSLog
import PhotosUI
import SwiftUI

extension Logger {
    init(category: String) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier ?? "app",
            category: category
        )
    }
}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
}

extension Array where Element: Equatable {
    mutating func replace(_ element: Element, with new: Element) {
        if let toReplace = firstIndex(where: { $0 == element }) {
            self[toReplace] = new
        }
    }
}

enum UserDefaultsKey: String, CaseIterable {
    case selectedTab = "selected_tab"
    case selectedSidebarTab = "selected_sidebar_tab"
    case isOnboardedOnDevice = "is_current_device_onboarded"
    case colorScheme = "color_scheme"
}

extension UserDefaults {
    func reset() {
        UserDefaultsKey.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}

extension UserDefaults {
    func set(_ value: Any, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func removeObject(for key: UserDefaultsKey) {
        removeObject(forKey: key.rawValue)
    }

    func bool(for key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func data(for key: UserDefaultsKey) -> Data? {
        data(forKey: key.rawValue)
    }

    func string(for key: UserDefaultsKey) -> String? {
        string(forKey: key.rawValue)
    }

    func integer(for key: UserDefaultsKey) -> Int? {
        integer(forKey: key.rawValue)
    }

    func float(for key: UserDefaultsKey) -> Float? {
        float(forKey: key.rawValue)
    }

    func url(for key: UserDefaultsKey) -> URL? {
        url(forKey: key.rawValue)
    }

    func value(for key: UserDefaultsKey) -> Any? {
        value(forKey: key.rawValue)
    }
}

public func clearTemporaryData() {
    let logger = Logger(category: "TempDataCleanUp")
    // Reset tab restoration
    UserDefaults.standard.removeObject(for: .selectedTab)

    // Reset NavigationStack restoration
    let fileEnvironmentModel = FileManager.default
    let filesToDelete = Tab.allCases.map(\.cachesPath)
    do {
        let directoryContents = try fileEnvironmentModel.contentsOfDirectory(
            at: URL.cachesDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )
        for file in directoryContents where filesToDelete.contains(file.lastPathComponent) {
            try fileEnvironmentModel.removeItem(at: file)
        }
    } catch {
        logger.error("Failed to delete navigation stack state restoration files. Error: \(error) (\(#file):\(#line))")
    }
}

@MainActor
public func getCurrentAppIcon() -> AppIcon {
    if let alternateAppIcon = UIApplication.shared.alternateIconName {
        return AppIcon(rawValue: alternateAppIcon) ?? AppIcon.ramune
    } else {
        return AppIcon.ramune
    }
}

public extension PhotosPickerItem {
    func getJPEG() async -> Data? {
        do {
            guard let imageData = try await loadTransferable(type: Data.self) else { return nil }
            guard let image = UIImage(data: imageData) else { return nil }
            return image.jpegData(compressionQuality: 0.1)
        } catch {
            return nil
        }
    }
}
