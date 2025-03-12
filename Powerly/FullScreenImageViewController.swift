//
//  FullScreenImageViewController.swift
//  PowerShare
//
//  Created by ADMIN on 02/08/23.
//  
//

import GooglePlaces
import UIKit

class FullScreenImageViewController: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var medias = [Any]()
    
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        pageControl.numberOfPages = medias.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let itemCount = imageCollectionView.numberOfItems(inSection: 0)
        if currentIndex < itemCount {
            self.imageCollectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.pageControl.currentPage = self.currentIndex
        }
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension FullScreenImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullPhotoCell", for: indexPath)
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if let media = medias.value(at: indexPath.item) {
                if let media = media as? Media {
                    imageView.sd_setImage(with: URL(string: media.url), placeholderImage: nil)
                } else if let metaData = media as? GMSPlacePhotoMetadata {
                    imageView.image = nil
                    let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: metaData, maxSize: CGSizeMake(screenWidth, screenHeight))
                    GMSPlacesClient.shared().fetchPhoto(with: fetchPhotoRequest, callback: {
                      (photoImage: UIImage?, error: Error?) in
                        guard let photoImage, error == nil else {
                            imageView.image = UIImage(named: "genaral_placeholder")
                          return }
                            imageView.image = photoImage
                      }
                    )
                } else if let data = media as? Data {
                    imageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
