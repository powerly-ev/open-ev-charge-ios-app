//
//  OnboardingViewController.swift
//  GasBottle
//
//  Created by admin on 04/10/22.
//  
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet var pageCollectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var letsGetStartedButton: UIButton!

    var pageViewController: OnboardingPageViewController? {
        didSet {
            pageViewController?.pagedelegate = self
        }
    }
    var pageCount: Int = 4 {
        didSet {
            if let pageCollectionView = self.pageCollectionView {
                pageCollectionView.reloadData()
            }
        }
    }
    var currentPage: Int = 0 {
        didSet {
            if let pageCollectionView = self.pageCollectionView {
                pageCollectionView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        if let pageCollectionView = self.pageCollectionView {
            pageCollectionView.dataSource = self
            pageCollectionView.delegate = self
            pageCollectionView.backgroundColor = .clear
            pageCollectionView.isScrollEnabled = false
        }
        skipButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        skipButton.setTitle(CommonUtils.getStringFromXML(name: "skip_title"), for: .normal)
        letsGetStartedButton.setTitle(CommonUtils.getStringFromXML(name: "next"), for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? OnboardingPageViewController {
            self.pageViewController = tutorialPageViewController
        }
    }
    
    @IBAction func didTapOnLetsGetStarted(_ sender: Any) {
        if self.currentPage == self.pageCount-1 {
            self.dismiss(animated: true)
            return
        }
        self.pageViewController?.scrollToNextViewController()
    }
    
    @IBAction func didTapOnSkipButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension OnboardingViewController: OnboardingPageViewControllerDelegate {
    func tutorialPageViewController(tutorialPageViewController: UIViewController, didUpdatePageCount count: Int) {
        pageCount = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: UIViewController, didUpdatePageIndex index: Int) {
        currentPage = index
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.className, for: indexPath) as? PageCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == currentPage {
            cell.selectedDotView.isHidden = false
            cell.unselectedDotView.isHidden = true
        } else {
            cell.selectedDotView.isHidden = true
            cell.unselectedDotView.isHidden = false
        }
        return cell
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = CGFloat(collectionView.bounds.width/CGFloat(self.pageCount+1))
        let height: CGFloat = 30.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
