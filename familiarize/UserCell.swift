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

class UserCell:  UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let cellId = "appCellId"
    
    // Padding for moving the user profile picture around
    // The amount of padding removes X amount of padding from the right side.
    // We have to compensate for the lost padding in the view controller by removing the width of the image when applying constraints
    let imageXCoordPadding: CGFloat = -230
    var onQuikklyCode: Bool = false
    var scannableView = ScannableView()
    var socialMediaInputs = [SocialMedia]()
    
    var cardProfileImage: UIImageView = {
        let image = UIManager.makeProfileImage(valueOfCornerRadius: 150)
        return image
    }()
    
    var codeProfileImage: UIImageView = {
        let image = UIManager.makeProfileImage(valueOfCornerRadius: 97)
        return image
    }()
    
    let bioLabel: UILabel = {
        let label = UIManager.makeLabel(numberOfLines: 1)
        return label
    }()
    
    let nameLabel: UILabel = {
        return UIManager.makeLabel(numberOfLines: 1)
    }()
    
    lazy var appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AppCell.self, forCellWithReuseIdentifier: self.cellId)
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    var myUserProfile: UserProfile? {
        didSet {
            let name = NSMutableAttributedString(string: (myUserProfile?.name)!, attributes: [NSFontAttributeName: UIFont(name: "ProximaNovaSoft-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor(red:47/255.0, green: 47/255.0, blue: 47/255.0, alpha: 1.0)])

            nameLabel.attributedText = name
            
            let bio = NSMutableAttributedString(string: (myUserProfile?.bio)!, attributes: [NSFontAttributeName: UIFont(name: "ProximaNovaSoft-Regular", size: 21)!, NSForegroundColorAttributeName: UIColor(red:144/255.0, green: 135/255.0, blue: 135/255.0, alpha: 1.0)])
            bioLabel.attributedText = bio
            
            // When myUserProfile is set within the UserController as a cell, then load up the required information that the user has.
            createQR(myUserProfile!)
            setupViews()
            
            let uniqueID = UInt64(self.myUserProfile!.uniqueID!)
            if let profileImage = myUserProfileImageCache.object(forKey: "\(uniqueID)" as NSString) {
                cardProfileImage.image = profileImage
            } else {
                guard let profileImage = DiskManager.readImageFromLocal(withUniqueID: uniqueID) else {
                    print("file was not able to be retrieved from disk")
                    return
                }
                cardProfileImage.image = profileImage
                myUserProfileImageCache.setObject(cardProfileImage.image!, forKey: "\(uniqueID)" as NSString)
            }
            codeProfileImage.image = cardProfileImage.image
    
            // We must purge all the data that is in socialMediaInputs due 
            // to the fact that user cells aren't destroyed when you move it out from view.
            // Instead, the cell is being recycled, and thus you need to remove all contents that it 
            // may have from previous cells.
            socialMediaInputs.removeAll(keepingCapacity: true)
            for key in myUserProfile!.entity.propertiesByName.keys {
                guard let inputName = myUserProfile!.value(forKey: key) else {
                    continue
                }
                if UserProfile.editableMultipleInputUserData.contains(key) {
                    for eachInput in inputName as! [String] {
                        let socialMediaInput = SocialMedia(withAppName: key, withImageName: "dan_\(key)_black", withInputName: eachInput, withAlreadySet: true)
                        //print(socialMediaInput.imageName!)
                        socialMediaInputs.append(socialMediaInput)
                    }
                }
            }
            
            // Refresh collectionview content with the social media inputs.
            appsCollectionView.reloadData()
        }
    }
    
    func setupViews() {
        for v in (self.subviews) {
            v.removeFromSuperview()
        }
        if onQuikklyCode == false {
            presentProfile()
        } else {
            presentScannableCode()
        }
    }

    func createQR(_ userProfile: UserProfile) {
        let skin = ScannableSkin()
        skin.backgroundColor = "#FFD705"
        skin.dotColor = "#2f2f2f"
        skin.borderColor = "#2f2f2f"
        skin.overlayColor = "#2f2f2f"
        skin.imageUri = ""
        skin.imageFit = .templateDefault
        skin.logoUri = ""
        
        let scannable = Scannable(withValue: userProfile.uniqueID as! UInt64, template: "template0014style3", skin: skin)
        scannableView.scannable = scannable
    }
    
    func presentScannableCode() {
        self.addSubview(scannableView)
        self.addSubview(codeProfileImage)
        scannableView.translatesAutoresizingMaskIntoConstraints = false
        scannableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        scannableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        scannableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scannableView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
        
        codeProfileImage.centerXAnchor.constraint(equalTo: scannableView.centerXAnchor, constant: 0).isActive = true
        codeProfileImage.centerYAnchor.constraint(equalTo: scannableView.centerYAnchor, constant: 0).isActive = true
        codeProfileImage.heightAnchor.constraint(equalToConstant: 194).isActive = true
        codeProfileImage.widthAnchor.constraint(equalToConstant: 194).isActive = true
    }
    
    func presentProfile() {
        addSubview(cardProfileImage)
        addSubview(nameLabel)
        addSubview(bioLabel)
        addSubview(appsCollectionView)
        
        cardProfileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        cardProfileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100).isActive = true
        cardProfileImage.heightAnchor.constraint(equalToConstant: 300).isActive = true
        //profileImage.widthAnchor.constraint(equalToConstant: 350 + (imageXCoordPadding/4)).isActive = true
        cardProfileImage.widthAnchor.constraint(equalToConstant: 300).isActive = true
        // We have to do imageXCoordPadding/4 because we are removing some pieces on the right side and have to compensate for it.
        
        //Namelabel position upated using NSLayoutConstraint -dan
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 170).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        bioLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bioLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 230).isActive = true
        bioLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        appsCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        appsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        appsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100).isActive = true
        appsCollectionView.heightAnchor.constraint(equalToConstant: 101).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialMediaInputs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
        cell.socialMedia = socialMediaInputs[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (socialMediaInputs.count == 2 ) {
            return CGSize(width: 140.0, height: 100)
        }
        if (socialMediaInputs.count >= 4) {
            return CGSize(width: 80.0, height: 100.0)
        }
        return CGSize(width: 120.0, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (socialMediaInputs.count == 1 ) {
            return UIEdgeInsetsMake(0, 127, 0, 127)
        } else if (socialMediaInputs.count == 2 ) {
            return UIEdgeInsetsMake(0, 42, 0, 42)
        } else if (socialMediaInputs.count == 3 ) {
            return UIEdgeInsetsMake(0, -1.5, 0, -1.5)
        } else {
            return UIEdgeInsetsMake(0, 10, 0, 10)
        }
    }
}


class AppCell: UICollectionViewCell {
    
    var socialMedia: SocialMedia? {
        didSet {
            if let appName = socialMedia?.appName {
                print(appName)
                print(appName.uppercased())
                socialMediaName.text = UIManager.makeRegularHandForDisplay(appName)
            }
            if let imageName = socialMedia?.imageName {
                socialMediaImage.image = UIImage(named: imageName)
            }
            setupViews()
        }
    }
    
    let socialMediaImage: UIImageView = {
        let image = UIManager.makeImage()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let socialMediaName: UILabel = {
        let label = UIManager.makeLabel()
        label.font = UIFont(name: "ProximaNovaSoft-Regular", size: 11)
        print("label.text = " , label.text!)
        print("label.text.uppercased() = " , label.text!.uppercased())
        
        label.text = label.text?.uppercased()
        return label
    }()
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(socialMediaImage)
        addSubview(socialMediaName)
        socialMediaImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        socialMediaImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant : -10).isActive = true
        
        
        socialMediaName.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        socialMediaName.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30).isActive = true
        
    }
}
