//
//  MediaCell.swift
//  Powerly
//
//  Created by ADMIN on 29/06/24.
//  
//
import GooglePlaces
import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    func loadImageFromPlaceMetaData(metaData: GMSPlacePhotoMetadata) {
        // Request individual photos in the response list
        let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: metaData, maxSize: CGSize(width: 160, height: 160))
        GMSPlacesClient.shared().fetchPhoto(with: fetchPhotoRequest, callback: {
          (photoImage: UIImage?, error: Error?) in
            guard let photoImage, error == nil else {
                self.mediaImageView.image = UIImage(named: "genaral_placeholder")
                return
            }
            self.mediaImageView.image = photoImage
          }
        )
    }
}
