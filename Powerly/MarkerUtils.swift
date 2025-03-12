//
//  MarkerUtils.swift
//  Powerly
//
//  Created by ADMIN on 20/06/24.
//  
//
import GoogleMaps
import UIKit

class MarkerUtils {
    static func createMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, rating: Float, markerImage: UIImage?, isGoogle: Bool = false) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.iconView = createMarkerView(rating: rating, markerImage: markerImage, isGoogle: isGoogle)
        marker.tracksViewChanges = true
        return marker
    }

    static func createMarkerView(rating: Float, markerImage: UIImage?, isGoogle: Bool) -> UIView {
        let markerView = UIView()
        markerView.translatesAutoresizingMaskIntoConstraints = false

        let pinImageView = UIImageView(image: markerImage)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.backgroundColor = UIColor.clear

        if !isGoogle {
            let infoView = UIView()
            infoView.translatesAutoresizingMaskIntoConstraints = false
            infoView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
            infoView.layer.cornerRadius = 5
            
            let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
            starIcon.tintColor = UIColor(named: "008CE9") ?? .black
            starIcon.contentMode = .scaleAspectFit
            starIcon.translatesAutoresizingMaskIntoConstraints = false

            let ratingLabel = UILabel()
            if rating == 0 {
                ratingLabel.text = NSLocalizedString("New", comment: "")
            } else {
                ratingLabel.text = String(format: "%.1f", rating)
            }
           
            ratingLabel.textColor = UIColor(named: "008CE9") ?? .black
            ratingLabel.textAlignment = .left
            ratingLabel.font = UIFont.systemFont(ofSize: 14)
            ratingLabel.translatesAutoresizingMaskIntoConstraints = false

            infoView.addSubview(starIcon)
            infoView.addSubview(ratingLabel)

            NSLayoutConstraint.activate([
                starIcon.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 2),
                starIcon.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),
                starIcon.widthAnchor.constraint(equalToConstant: 16),
                starIcon.heightAnchor.constraint(equalToConstant: 20),
                
                ratingLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 2),
                ratingLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -2),
                ratingLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor)
            ])

            markerView.addSubview(infoView)
            markerView.addSubview(pinImageView)

            NSLayoutConstraint.activate([
                infoView.topAnchor.constraint(equalTo: markerView.topAnchor, constant: 0),
                infoView.leadingAnchor.constraint(equalTo: markerView.leadingAnchor, constant: 0),
                infoView.trailingAnchor.constraint(equalTo: markerView.trailingAnchor, constant: 0),
                infoView.heightAnchor.constraint(equalToConstant: 25),
                
                pinImageView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 0),
                pinImageView.centerXAnchor.constraint(equalTo: markerView.centerXAnchor),
                pinImageView.widthAnchor.constraint(equalToConstant: 50),
                pinImageView.heightAnchor.constraint(equalToConstant: 40),
                pinImageView.bottomAnchor.constraint(equalTo: markerView.bottomAnchor, constant: 0)
            ])
        } else {
            markerView.addSubview(pinImageView)
            NSLayoutConstraint.activate([
                pinImageView.topAnchor.constraint(equalTo: markerView.topAnchor, constant: 0),
                pinImageView.leadingAnchor.constraint(equalTo: markerView.leadingAnchor, constant: 0),
                pinImageView.trailingAnchor.constraint(equalTo: markerView.trailingAnchor, constant: 0),
                pinImageView.widthAnchor.constraint(equalToConstant: 50),
                pinImageView.heightAnchor.constraint(equalToConstant: 40),
                pinImageView.bottomAnchor.constraint(equalTo: markerView.bottomAnchor, constant: 0)
            ])
        }
        return markerView
    }
    
    static func currentDayOfWeek() -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let dayNumber = calendar.component(.weekday, from: currentDate) - 1
        return dayNumber
    }
}
