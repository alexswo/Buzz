//
//  TabBarController.swift
//  familiarize
//
//  Created by Daniel Park on 7/9/17.
//  Copyright © 2017 nosleep. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import RevealingSplashView

extension ESTabBarController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
}

extension Notification.Name {
    static let removeScanner = Notification.Name("removeScanner")
    static let logInController = Notification.Name("logInController")
    static let loggedInController = Notification.Name("loggedInController")
}

protocol TabBarControllerDelegate: class {
    func setupTabBarControllers()
}

class TabBarController: ESTabBarController, UITabBarControllerDelegate, TabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeScanner), name: .removeScanner, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupLogInController), name: .logInController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUserDataOnLogIn), name: .loggedInController, object: nil)

        // If you just logged in, then the revealing splashview will not show.
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "bee")!,iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: UIColor(red: 255/255.0, green: 203/255.0, blue: 0/255.0, alpha:1.0))
        view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation()
        
        if isNotFirstTime() {
            setupTabBarControllers()
        } else {
            perform(#selector(showWalkthroughController), with: nil, afterDelay: 0.93)
        }
    }
    
    func setupTabBarControllers() {
        // If user is not already logged in, present the login controller.
        // Else, if user is already logged in, go and present the tab bar controller.
        if FirebaseManager.isUserLoggedIn() == nil {
            setupLogInController()
        } else {
            setupLoggedInController()
        }
    }
    
    func setupLogInController() {
        let loginController = LoginController()
        let loginNavigationController = UINavigationController(rootViewController: loginController)
        tabBar.isHidden = true
        viewControllers?.removeAll()
        viewControllers = [loginNavigationController]
    }
    
    func fetchUserDataOnLogIn() {
        let userProfiles = [UserProfile.userProfileSelection.myUser, UserProfile.userProfileSelection.otherUser]
        for userProfile in userProfiles {
            FirebaseManager.getCards(userProfileSelection: userProfile, completionHandler: { (fetchedCardObjects) in
                guard let fetchedCardObjects = fetchedCardObjects else { return }
                for fetchedCardObject in fetchedCardObjects {
                    guard let card = fetchedCardObject.card else { return }
                    guard let uniqueID = fetchedCardObject.uniqueID else { return }
                    guard let userProfile = UserProfile.saveProfile(card, forProfile: userProfile, withUniqueID: uniqueID) else { return }
                    let socialMedia = SocialMedia(withAppName: (userProfile.profileImageApp)!, withImageName: "", withInputName: (userProfile.profileImageURL)!, withAlreadySet: false)
                    ImageFetchingManager.fetchImages(withSocialMediaInputs: [socialMedia], completionHandler: { fetchedSocialMediaProfileImages in
                        if let profileImage = fetchedSocialMediaProfileImages[0].profileImage {
                            DiskManager.writeImageDataToLocal(withData: UIImagePNGRepresentation(profileImage)!, withUniqueID: userProfile.uniqueID as! UInt64, withUserProfileSelection: UserProfile.userProfileSelection.otherUser)
                        }
                    })
                }
            })
        }
        setupLoggedInController()
    }
    
    func setupLoggedInController() {
        let tabBarController = ESTabBarController()
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.barTintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha:1.0)
        //User Controller
        let userController = UserController(collectionViewLayout: UICollectionViewFlowLayout())
        let userNavigationController = UINavigationController(rootViewController: userController)
        userController.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "dan_me_grey"), selectedImage: UIImage(named: "dan_me_black"))
        
        //Scanner Controller
        let scannerController = ScannerController()
        let scannerNavigationController = UINavigationController(rootViewController: scannerController)
        scannerController.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(),title: nil, image: UIImage(named: "dan_tabbarcircle_orange_25"), selectedImage: UIImage(named: "dan_tabbarcircle_orange_25"))
        
        //Contacts Controller
        //let contactsController = ContactsController(collectionViewLayout: UICollectionViewFlowLayout())
        let contactsController = ContactsController(style: UITableViewStyle.plain)
        let contactsNavigationController = UINavigationController(rootViewController: contactsController)
        contactsController.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "dan_friends_grey"), selectedImage: UIImage(named: "dan_friends_black"))
        
        tabBar.isHidden = false
        viewControllers?.removeAll()
        viewControllers = [userNavigationController, scannerNavigationController, contactsNavigationController]
    }
    
    fileprivate func isNotFirstTime() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNotFirstTime")
    }
    
    func showWalkthroughController() {
        let walkthroughController = WalkthroughController()
        walkthroughController.tabBarControllerDelegate = self
        present(walkthroughController, animated: false)
    }

    func removeScanner() {
        viewControllers?.remove(at: 1)
        //Scanner Controller
        let scannerController = ScannerController()
        let scannerNavigationController = UINavigationController(rootViewController: scannerController)
        scannerController.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(),title: nil, image: UIImage(named: "dan_tabbarcircle_orange_25"), selectedImage: UIImage(named: "dan_tabbarcircle_orange_25"))
        viewControllers?.insert(scannerNavigationController, at: 1)
    }
}
