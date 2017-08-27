//
//  UserCell.swift
//  familiarize
//
//  Created by Alex Oh on 6/1/17.
//  Copyright © 2017 nosleep. All rights reserved.
//

import QRCode
import SwiftyJSON
import UIKit
import Quikkly

var myUserProfileImageCache = NSCache<NSString, UIImage>()

class UserCell: UICollectionViewCell {
    
    var fullBrightness: Bool = false
    
    // Padding for moving the user profile picture around
    // The amount of padding removes X amount of padding from the right side.
    // We have to compensate for the lost padding in the view controller by removing the width of the image when applying constraints
    let imageXCoordPadding: CGFloat = -230
    var onQRImage: Bool = true
    var scannableView:ScannableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scannableView = ScannableView()
        NotificationCenter.default.addObserver(self, selector: #selector(manageBrightness), name: .UIScreenBrightnessDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func manageBrightness() {
        if (self.fullBrightness == true) {
            //UIScreen.main.brightness = 1.0
        } else {
            //let delegate = UIApplication.shared.delegate as! AppDelegate
            //UIScreen.main.brightness = delegate.userBrightnessLevel
        }
    }
    
    var myUserProfile: UserProfile? {
        didSet {
            let name = NSMutableAttributedString(string: (myUserProfile?.name)!, attributes: [NSFontAttributeName: UIFont(name: "ProximaNovaSoft-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor(red:47/255.0, green: 47/255.0, blue: 47/255.0, alpha: 1.0)])
            nameLabel.attributedText = name
            
            let bio = NSMutableAttributedString(string: (myUserProfile?.bio)!, attributes: [NSFontAttributeName: UIFont(name: "ProximaNovaSoft-Regular", size: 21)!, NSForegroundColorAttributeName: UIColor(red:144/255.0, green: 135/255.0, blue: 135/255.0, alpha: 1.0)])
            bioLabel.attributedText = bio
            
            // When myUserProfile is set within the UserController as a cell, then load up the required information that the user has.
            createQR(myUserProfile!)
            setupViews()
            
            if let profileImage = myUserProfileImageCache.object(forKey: "\(self.myUserProfile!.uniqueID!)" as NSString) {
                self.profileImage.image = profileImage
            } else {
                
                guard let profileImage = DiskManager.readImageFromLocal(withUniqueID: self.myUserProfile!.uniqueID as! UInt64) else {
                    print("file was not able to be retrieved from disk")
                    return
                }
                
                self.profileImage.image = profileImage
                myUserProfileImageCache.setObject(self.profileImage.image!, forKey: "\(self.myUserProfile!.uniqueID!)" as NSString)

            }
        }
    }

    func createQR(_ userProfile: UserProfile) {
        let skin = ScannableSkin()
        skin.backgroundColor = "#ffe769"
        //skin.maskColor = "#2f2f2f"
        skin.dotColor = "#2f2f2f"
        skin.borderColor = "#2f2f2f"
        //skin.overlayColor = "#ffd705"
        skin.imageUri = "http://i.imgur.com/JDpYmVp.gif"
        skin.imageFit = .templateDefault
        skin.logoUri = ""
        
        let scannable = Scannable(withValue: userProfile.uniqueID as! UInt64, template: "template0014style3", skin: skin)
        self.scannableView.scannable = scannable
    }
    
    var profileImage: UIImageView = {
        let image = UIManager.makeImage()
        image.clipsToBounds = true
        image.contentMode = UIViewContentMode.scaleAspectFill
        return image
    }()
    
    let bioLabel: UILabel = {
        let label = UIManager.makeLabel(numberOfLines: 1)
        return label
    }()
    
    let nameLabel: UILabel = {
        return UIManager.makeLabel(numberOfLines: 1)
    }()
    
    
    func flipCard() {
        for v in (self.subviews){
            v.removeFromSuperview()
        }
        
        if onQRImage == true {
            presentProfile()
        } else {
            presentScannableCode()
        }
    }
    
    func presentScannableCode() {
        self.addSubview(self.scannableView)
        scannableView.translatesAutoresizingMaskIntoConstraints = false
        scannableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        scannableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        scannableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scannableView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
    }

    func presentProfile() {
        addSubview(profileImage)
        profileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 300).isActive = true
        //profileImage.widthAnchor.constraint(equalToConstant: 350 + (imageXCoordPadding/4)).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 300).isActive = true
        // We have to do imageXCoordPadding/4 because we are removing some pieces on the right side and have to compensate for it.
        
        //Namelabel position upated using NSLayoutConstraint -dan
        addSubview(nameLabel)
        addSubview(bioLabel)
        
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 180).isActive = true
        //nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 35).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        bioLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bioLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 240).isActive = true
        //bioLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 35).isActive = true
        //bioLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        bioLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        //presentAngularSocialMediaButtons()
        presentLinearSocialMediaButtons()
    }
    
    func setupViews() {
        flipCard()
    }
    
    lazy var socialMediaImages: [String: UIImageView] = [
        //temporary icons while we wait for new icons from our graphic designers
        "phoneNumber": UIManager.makeImage(imageName: "dan_phone_black"),
        "faceBookProfile": UIManager.makeImage(imageName: "dan_facebook_black"),
        "instagramProfile": UIManager.makeImage(imageName: "dan_instagram_black"),
        "snapChatProfile": UIManager.makeImage(imageName: "dan_snapchat_black"),
        "linkedInProfile": UIManager.makeImage(imageName: "dan_linkedin_black"),
        "email": UIManager.makeImage(imageName: "dan_email_black"),
        "twitterProfile": UIManager.makeImage(imageName: "dan_twitter_black"),
        "soundCloudProfile": UIManager.makeImage(imageName: "dan_soundcloud_black"),
        ]
    
    //todo: this is old code - change to collectionview
    func presentLinearSocialMediaButtons() {
        var imagesToPresent = [UIImageView]()
        for key in (myUserProfile?.entity.attributesByName.keys)! {
            if (myUserProfile?.value(forKey: key) != nil && socialMediaImages[key] != nil) {
                imagesToPresent.insert(socialMediaImages[key]!, at: 0)
            }
        }
        let size = imagesToPresent.count
        var xConstant : CGFloat = 0
        var count = 0
        if size == 1 {
            for image in imagesToPresent {
                self.addSubview(image)
                image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor).isActive = true
                image.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor, constant: 55).isActive = true
                image.heightAnchor.constraint(equalToConstant: 40).isActive = true
                image.widthAnchor.constraint(equalToConstant: 40).isActive = true
            }
        } else if size == 2 {
            xConstant = 50
            count = 0
            for image in imagesToPresent {
                self.addSubview(image)
                if count == 0 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: -xConstant).isActive = true
                } else if count == 1 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: xConstant).isActive = true
                }
                image.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor, constant: 55).isActive = true
                image.heightAnchor.constraint(equalToConstant: 40).isActive = true
                image.widthAnchor.constraint(equalToConstant: 40).isActive = true
                count += 1
            }
        } else if size == 3 {
            xConstant = 80
            count = 0
            for image in imagesToPresent {
                self.addSubview(image)
                if count == 0 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: -xConstant).isActive = true
                } else if count == 1 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor).isActive = true
                } else if count == 2 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: xConstant).isActive = true
                }
                image.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor, constant: 55).isActive = true
                image.heightAnchor.constraint(equalToConstant: 40).isActive = true
                image.widthAnchor.constraint(equalToConstant: 40).isActive = true
                count += 1
            }
        } else if size == 4 {
            xConstant = 40
            count = 0
            for image in imagesToPresent {
                self.addSubview(image)
                if count == 0 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: -3*xConstant).isActive = true
                } else if count == 1 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: -xConstant).isActive = true
                } else if count == 2 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: xConstant).isActive = true
                } else if count == 3 {
                    image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: 3*xConstant).isActive = true
                }
                image.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor, constant: 55).isActive = true
                image.heightAnchor.constraint(equalToConstant: 40).isActive = true
                image.widthAnchor.constraint(equalToConstant: 40).isActive = true
                count += 1
            }
        } else if size == 5 {
            
        } else if size == 6 {
            
        }
    }
    
    func autoLinearSpaceButtons(imagesToPresent: [UIImageView]) {
        var count = 0
        for image in imagesToPresent {
            self.addSubview(image)
            image.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor, constant: 50 ).isActive = true
            image.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor, constant: 50).isActive = true
            image.heightAnchor.constraint(equalToConstant: 50).isActive = true
            image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    // Helper function to space out social media icons - dan
    func autoAngularSpaceButtons(r: Double, theta1: Double, theta2: Double, imagesToPresent: [UIImageView]){
        var count = 0
        for image in imagesToPresent{
            self.addSubview(image)
            image.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor, constant: CGFloat(r * cos(theta1 + Double(count) * theta2) + 30)).isActive = true
            image.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: CGFloat(r * sin(theta1 + Double(count) * theta2))).isActive = true
            image.heightAnchor.constraint(equalToConstant: 50).isActive = true
            image.widthAnchor.constraint(equalToConstant: 50).isActive = true
            count += 1
        }
    }
    
    // Function to space out social media icons evenly around the profile picture at an equal distance -dan
    func presentAngularSocialMediaButtons() {
        var my_imagesToPresent = [UIImageView]()
        for key in (myUserProfile?.entity.attributesByName.keys)! {
            if (myUserProfile?.value(forKey: key) != nil && socialMediaImages[key] != nil) {
                my_imagesToPresent.insert(socialMediaImages[key]!, at: 0)
            }
        }
        let size = my_imagesToPresent.count
        var my_theta1 = 0.0
        var my_theta2 = 0.0
        let rad = 57.2958
        if size == 1 {
            my_theta1 = 110.0
            my_theta2 = 35.0
        } else if size == 2 {
            my_theta1 = 110.0
            my_theta2 = 35.0
        } else if size == 3 {
            my_theta1 = 110.0
            my_theta2 = 35.0
        } else if size == 4 {
            my_theta1 = 110.0
            my_theta2 = 30.0
        } else if size == 5 {
            my_theta1 = 95.0
            my_theta2 = 25.0
        } else if size == 6 {
            my_theta1 = 80.0
            my_theta2 = 25.0
        } else {
            
        }
        
        autoAngularSpaceButtons(r: 220.0, theta1: my_theta1 / rad, theta2: my_theta2 / rad, imagesToPresent: my_imagesToPresent)
    }
}
