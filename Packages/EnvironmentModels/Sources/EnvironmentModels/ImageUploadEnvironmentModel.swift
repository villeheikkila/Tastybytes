import Extensions
import Models
import Observation
import OSLog
import Repositories
import SwiftUI

@Observable
public class ImageUploadEnvironmentModel {
    private let logger = Logger(category: "PermissionEnvironmentModel")

    public var uploadedImageForCheckIn: CheckIn?
    public var alertError: AlertError?

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func uploadCheckInImage(checkIn: CheckIn, image: UIImage) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.7) else { return }
            switch await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id) {
            case let .success(imageFile):
                await MainActor.run {
                    uploadedImageForCheckIn = checkIn.copyWith(imageFile: imageFile)
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
