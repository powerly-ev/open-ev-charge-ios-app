@preconcurrency import PhotosUI
import UIKit

@available(iOS 14.0, *)
extension PHPickerResult {
    func loadImageData(maxSizeInBytes: Int) async throws -> Data? {
        try await withCheckedThrowingContinuation { continuation in
            if self.itemProvider.canLoadObject(ofClass: UIImage.self) {
                self.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let image = image as? UIImage {
                        let compressedImageData = compressImage(image: image, maxSizeInBytes: maxSizeInBytes)
                        continuation.resume(returning: compressedImageData)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    private func compressImage(image: UIImage, maxSizeInBytes: Int) -> Data? {
        // Compression logic here, adjust as needed
        var compression: CGFloat = 1.0
        guard var imageData = image.jpegData(compressionQuality: compression) else { return nil }

        while imageData.count > maxSizeInBytes && compression > 0 {
            compression -= 0.1
            if let data = image.jpegData(compressionQuality: compression) {
                imageData = data
            }
        }
        return imageData
    }
}
