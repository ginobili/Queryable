/*
See the License.txt file for this sample’s licensing information.
*/

import Photos
import os.log

struct PhotoAsset: Identifiable {
    var id: String { identifier }
    var identifier: String = UUID().uuidString
    var index: Int?
    var phAsset: PHAsset?
    
    // New property for class label
    var classLabel: String? // Add this line
    
    typealias MediaType = PHAssetMediaType
    
    var isFavorite: Bool {
        phAsset?.isFavorite ?? false
    }
    
    var mediaType: MediaType {
        phAsset?.mediaType ?? .unknown
    }
    
    var accessibilityLabel: String {
        isFavorite ? "Photo, Favorite" : "Photo"
    }

    // Updated initializer to include classLabel
    init(phAsset: PHAsset, index: Int?, classLabel: String? = nil) { // Modify this line
        self.phAsset = phAsset
        self.index = index
        self.identifier = phAsset.localIdentifier
        self.classLabel = classLabel // Add this line
    }
    
    init(identifier: String, classLabel: String? = nil) { // Modify this initializer
        self.identifier = identifier
        self.classLabel = classLabel // Add this line
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        self.phAsset = fetchedAssets.firstObject
    }
    
    func setIsFavorite(_ isFavorite: Bool) async {
        guard let phAsset = phAsset else { return }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: phAsset)
                request.isFavorite = isFavorite
            }
        } catch (let error) {
            print("Failed to change isFavorite: \(error.localizedDescription)")
            logger.error("Failed to change isFavorite: \(error.localizedDescription)")
        }
    }
    
    func delete() async {
        guard let phAsset = phAsset else { return }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets([phAsset] as NSArray)
            }
            logger.debug("PhotoAsset asset deleted: \(index ?? -1)")
        } catch (let error) {
            print("Failed to delete photo: \(error.localizedDescription)")
            logger.error("Failed to delete photo: \(error.localizedDescription)")
        }
    }
}

extension PhotoAsset: Equatable {
    static func ==(lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        (lhs.identifier == rhs.identifier) && (lhs.isFavorite == rhs.isFavorite)
    }
}

extension PhotoAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension PHObject: Identifiable {
    public var id: String { localIdentifier }
}

fileprivate let logger = Logger(subsystem: "com.mazzystar.Queryable", category: "PhotoAsset")
