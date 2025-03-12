//
//  UIView.swift
//  PowerShare
//
//  Created by admin on 21/10/21.

//

import Foundation
import UIKit

extension UIView {
   func addButtonDropshadowtoVIEW() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "222222")?.cgColor
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.3
    }
    
    func addOnlyDropshadowtoVIEW() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "HEADER_TEXT")?.cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowOpacity = 0.2
    }
    
    func addOnlyUppershadowtoVIEW() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "HEADER_TEXT")?.cgColor
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0.0, height: -4.0)
        layer.shadowOpacity = 0.2
    }
    
    func addDropshadowtoVIEW() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "HEADER_TEXT")?.cgColor
        layer.shadowRadius = 17
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.2
    }
    
    func addDropshadowtoVIEW(radius: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "HEADER_TEXT")?.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.2
    }
    
    func addLightDropshadowtoVIEW() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "HEADER_TEXT")?.cgColor
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.1
    }
    
    func setCornerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func setBorderWidth(width: CGFloat) {
        layer.borderWidth = width
    }
    
    func setBorderColor(color: UIColor?) {
        layer.borderColor = color?.cgColor
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
   }
    
    func setTopCornersRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
    }
    
    func setBottomCornersRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.layer.masksToBounds = true
    }
    
    func setLeftCornersRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }

        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }

        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func loadViewFromNib() {
        let nibName = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
        guard let view = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
        setNeedsUpdateConstraints()
    }

    func setAllSideContraints(_ insets: UIEdgeInsets) {
        guard let view = superview else {
            return
        }
        topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom).isActive = true
    }
}

extension UIView {

  @discardableResult
  func anchor(top: NSLayoutYAxisAnchor? = nil,
              left: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil,
              right: NSLayoutXAxisAnchor? = nil,
              paddingTop: CGFloat = 0,
              paddingLeft: CGFloat = 0,
              paddingBottom: CGFloat = 0,
              paddingRight: CGFloat = 0,
              width: CGFloat = 0,
              height: CGFloat = 0) -> [NSLayoutConstraint] {
    translatesAutoresizingMaskIntoConstraints = false

    var anchors = [NSLayoutConstraint]()

    if let top = top {
      anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
    }
    if let left = left {
      anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
    }
    if let bottom = bottom {
      anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
    }
    if let right = right {
      anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
    }
    if width > 0 {
      anchors.append(widthAnchor.constraint(equalToConstant: width))
    }
    if height > 0 {
      anchors.append(heightAnchor.constraint(equalToConstant: height))
    }

    anchors.forEach { $0.isActive = true }

    return anchors
  }

  @discardableResult
  func anchorToSuperview() -> [NSLayoutConstraint] {
    return anchor(top: superview?.topAnchor,
                  left: superview?.leftAnchor,
                  bottom: superview?.bottomAnchor,
                  right: superview?.rightAnchor)
  }
}

extension UIView {

  func applyShadow(radius: CGFloat,
                   opacity: Float,
                   offset: CGSize,
                   color: UIColor = .black) {
    layer.shadowRadius = radius
    layer.shadowOpacity = opacity
    layer.shadowOffset = offset
    layer.shadowColor = color.cgColor
  }
}

extension UIView {
    func takeScreenshot() -> UIImage? {
        var screenshotImage: UIImage?
        let layer = self.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        self.drawHierarchy(in: layer.bounds, afterScreenUpdates: true)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
}
