import SwiftUI
import Photos

struct ThumbnailView: View {
    let phAsset: PHAsset?
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
                ProgressView()
            }
        }
        .frame(width: 50, height: 50)
        .clipped()
        .onAppear {
            loadThumbnail()
        }
    }

    func loadThumbnail() {
        guard let phAsset = phAsset else { return }
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = .fast

        PHImageManager.default().requestImage(
            for: phAsset,
            targetSize: CGSize(width: 50, height: 50), // Adjust as needed
            contentMode: .aspectFill,
            options: options) { result, info in
                if let result = result {
                    self.image = result
                }
            }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(phAsset: nil)
            .previewLayout(.sizeThatFits)
    }
}
