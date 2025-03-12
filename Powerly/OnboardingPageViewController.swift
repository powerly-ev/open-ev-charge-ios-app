//
//  OnboardingPageViewController.swift
//  GasBottle
//
//  Created by admin on 04/10/22.
//  
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    private(set) lazy var onboardingViewControllers: [UIViewController] = {
        self.isScrollEnabled = true
        
        guard let tutorial1 = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: TutorialViewController.className) as? TutorialViewController else {
            return []
        }
        tutorial1.tutorialImage = UIImage(named: "tutorial_1")
        let attrTitle1 = NSMutableAttributedString()
        if isLanguageArabic {
            attrTitle1.custom("\(NSLocalizedString("Drive to Station", comment: "")) ", font: .robotoBold(ofSize: 28), color: UIColor(named: "008CE9") ?? .blue)
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "location.fill")
            let imageBounds = CGRect(x: 0, y: -4, width: 24, height: 24)
            imageAttachment.bounds = imageBounds
            let imageString = NSAttributedString(attachment: imageAttachment)
            attrTitle1.append(imageString)
            
            attrTitle1.custom("\(NSLocalizedString("Safely", comment: "")) ", font: .robotoBold(ofSize: 28), color: UIColor(named: "222222") ?? .black)
        } else {
            attrTitle1.custom("\(NSLocalizedString("Safely", comment: "")) ", font: .robotoBold(ofSize: 28), color: UIColor(named: "222222") ?? .black)
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "location.fill")
            let imageBounds = CGRect(x: 0, y: -4, width: 24, height: 24)
            imageAttachment.bounds = imageBounds
            let imageString = NSAttributedString(attachment: imageAttachment)
            attrTitle1.append(imageString)
            
            attrTitle1.custom(" \(NSLocalizedString("Drive to Station", comment: ""))", font: .robotoBold(ofSize: 28), color: UIColor(named: "008CE9") ?? .blue)
        }
        
        tutorial1.attrTitle = attrTitle1
        tutorial1.strDescription = NSLocalizedString("Locate your charger with the app and head to its location. The map will guide you for easy navigation.", comment: "")
        
        guard let tutorial2 = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: TutorialViewController.className) as? TutorialViewController else {
            return []
        }
        tutorial2.tutorialImage = UIImage(named: "tutorial_2")
        let attrTitle2 = NSMutableAttributedString()
        attrTitle2.custom(NSLocalizedString("Identify the Charger", comment: ""), font: .robotoBold(ofSize: 28), color: UIColor(named: "222222") ?? .black)
        tutorial2.attrTitle = attrTitle2
        let attrDescripition2 = NSMutableAttributedString()
        if isLanguageArabic {
            attrDescripition2.custom("في المناطق التي تحتوي على عدة شواحن، حدد شاحنك باستخدام الرقم التعريفي الفريد أو الاسم، ", font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
            
            let imageAttachment2 = NSTextAttachment()
            imageAttachment2.image = UIImage(systemName: "calendar.badge.plus")
            let imageBounds2 = CGRect(x: 0, y: -4, width: 18, height: 16)
            imageAttachment2.bounds = imageBounds2
            let imageString2 = NSAttributedString(attachment: imageAttachment2)
            attrDescripition2.append(imageString2)
            attrDescripition2.custom(NSLocalizedString("booked in advance.", comment: ""), font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .black)
            
            attrDescripition2.custom(" من خلال التطبيق.", font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
            tutorial2.attrDescription = attrDescripition2
        } else {
            attrDescripition2.custom(NSLocalizedString("In areas with multiple chargers, identify your charger using its unique ID or name, especially helpful if you have ", comment: ""), font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
            
            let imageAttachment2 = NSTextAttachment()
            imageAttachment2.image = UIImage(systemName: "calendar.badge.plus")
            let imageBounds2 = CGRect(x: 0, y: -4, width: 18, height: 16)
            imageAttachment2.bounds = imageBounds2
            let imageString2 = NSAttributedString(attachment: imageAttachment2)
            attrDescripition2.append(imageString2)
            
            attrDescripition2.custom(" \(NSLocalizedString("booked in advance.", comment: ""))", font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .black)
            tutorial2.attrDescription = attrDescripition2
        }

        guard let tutorial3 = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: TutorialViewController.className) as? TutorialViewController else {
            return []
        }
        tutorial3.tutorialImage = UIImage(named: "tutorial_3")
        let attrTitle3 = NSMutableAttributedString()
        attrTitle3.custom(NSLocalizedString("Start Charger", comment: ""), font: .robotoBold(ofSize: 28), color: UIColor(named: "222222") ?? .black)
        tutorial3.attrTitle = attrTitle3
        
        let attrDescripition3 = NSMutableAttributedString()
        if isLanguageArabic {
            attrDescripition3.custom("أولاً، قم بتوصيل سيارتك بالشاحن. ثم، قم بمسح رمز الاستجابة السريعة (رمز QR) على الشاحن ", font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
            let imageAttachment3 = NSTextAttachment()
            imageAttachment3.image = UIImage(named: "Bolt")
            let imageBounds3 = CGRect(x: 0, y: -4, width: 16, height: 16)
            imageAttachment3.bounds = imageBounds3
            let imageString3 = NSAttributedString(attachment: imageAttachment3)
            attrDescripition3.append(imageString3)
            
            attrDescripition3.custom("\(NSLocalizedString("start the charging", comment: "")) ", font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .black)
            attrDescripition3.custom("، ثم اضغط على بدء الشحن من التطبيق.", font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
        } else {
            attrDescripition3.custom(NSLocalizedString("First, connect your vehicle to the charger. Then, scan the QR code on the charger to\n", comment: ""), font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
            let imageAttachment3 = NSTextAttachment()
            imageAttachment3.image = UIImage(named: "Bolt")
            let imageBounds3 = CGRect(x: 0, y: -4, width: 16, height: 16)
            imageAttachment3.bounds = imageBounds3
            let imageString3 = NSAttributedString(attachment: imageAttachment3)
            attrDescripition3.append(imageString3)
            
            attrDescripition3.custom(" \(NSLocalizedString("start the charging", comment: "")) ", font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .black)
            attrDescripition3.custom(NSLocalizedString("process.", comment: ""), font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
        }

        tutorial3.attrDescription = attrDescripition3
        
        guard let tutorial4 = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: TutorialViewController.className) as? TutorialViewController else {
            return []
        }
        tutorial4.tutorialImage = UIImage(named: "tutorial_4")
        let attrTitle4 = NSMutableAttributedString()
        attrTitle4.custom(NSLocalizedString("Wait", comment: ""), font: .robotoBold(ofSize: 28), color: UIColor(named: "008CE9") ?? .blue)
        attrTitle4.custom(" \(NSLocalizedString("for Charging", comment: ""))", font: .robotoBold(ofSize: 28), color: UIColor(named: "222222") ?? .black)
        tutorial4.attrTitle = attrTitle4
        let attrDescripition4 = NSMutableAttributedString()
        attrDescripition4.custom(NSLocalizedString("Setup complete! A countdown timer will show how long until your vehicle is fully charged. Relax or take a moment for yourself in the meantime.", comment: ""), font: .robotoMedium(ofSize: 16), color: UIColor(named: "222222") ?? .black)
        tutorial4.attrDescription = attrDescripition4
        
        var arrVC = [
            tutorial1,
            tutorial2,
            tutorial3,
            tutorial4
        ]
        return arrVC
    }()
    
    // MARK: Object lifecycle
    var pagedelegate: OnboardingPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let initialViewController = onboardingViewControllers.first {
            scrollToViewController(viewController: initialViewController)
            pagedelegate?.tutorialPageViewController(tutorialPageViewController: initialViewController, didUpdatePageCount: onboardingViewControllers.count)
        }
        // Do any additional setup after loading the view.
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
                    scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = onboardingViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
                let nextViewController = onboardingViewControllers[newIndex]
                scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
            direction: direction,
            animated: true,
            completion: { _ in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = onboardingViewControllers.firstIndex(of: firstViewController) {
            pagedelegate?.tutorialPageViewController(tutorialPageViewController: firstViewController, didUpdatePageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = onboardingViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                return onboardingViewControllers.last
            }
            
            guard onboardingViewControllers.count > previousIndex else {
                return nil
            }
            
            return onboardingViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = onboardingViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = onboardingViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return onboardingViewControllers.first
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return onboardingViewControllers[nextIndex]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
        print("page controller moved")
     }
}

extension UIPageViewController {

    var scrollView: UIScrollView {
        for subview in view.subviews {
            if let scrollview = subview as? UIScrollView {
                return scrollview
            }
        }
        fatalError()
    }
    
    var isScrollEnabled: Bool {
        get {
            return scrollView.isScrollEnabled
        }
        set {
            scrollView.isScrollEnabled = newValue
        }
    }
}

protocol OnboardingPageViewControllerDelegate: AnyObject {
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: UIViewController, didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: UIViewController, didUpdatePageIndex index: Int)
}
