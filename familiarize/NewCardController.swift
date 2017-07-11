//
//  NewCardController.swift
//  familiarize
//
//  Created by Alex Oh on 7/5/17.
//  Copyright © 2017 nosleep. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

protocol NewCardControllerDelegate {
    func presentSocialMediaPopup(socialMedia: SocialMedia) -> Void
    func addSocialMediaInput(socialMedia: SocialMedia) -> Void
}

class NewCardController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NewCardControllerDelegate {

    var optionalSocialMediaInputs: [SocialMedia] = []
    var userControllerDelegate: UserControllerDelegate?

    var requiredSocialMediaInputs: [SocialMedia] = [
        SocialMedia(withSocialMedia: "name", withImageName: "dan_facebook_red", withInputName: "Required", withAlreadySet: true),
        SocialMedia(withSocialMedia: "bio", withImageName: "dan_facebook_red", withInputName: "Optional", withAlreadySet: true)
    ]
    
    
    private let socialMediaSelectionCellId = "socialMediaSelectionCellId"
    private let socialMediaSelectedCellId = "socialMediaSelectedCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Card"
        setupCollectionView()
        setupNavBarButton()
    }
    
    //# MARK: - Header Collection View
    
    // This is our header. Independent of the social media inputs. 
    // This calls the SocialMediaSelectionCell class.
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: socialMediaSelectionCellId, for: indexPath) as! SocialMediaSelectionCell
        cell.newCardControllerDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

    //# MARK: - Body Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionalSocialMediaInputs.count + requiredSocialMediaInputs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: socialMediaSelectedCellId, for: indexPath) as! SocialMediaSelectedCell
        if indexPath.item < requiredSocialMediaInputs.count {
            cell.selectedSocialMedia = requiredSocialMediaInputs[indexPath.item]
        } else { //if indexPath.item >= optionalSocialMediaInputs.count
            cell.selectedSocialMedia = optionalSocialMediaInputs[indexPath.item - requiredSocialMediaInputs.count]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < requiredSocialMediaInputs.count {
            self.presentSocialMediaPopup(socialMedia: requiredSocialMediaInputs[indexPath.item])
        } else {
            self.presentSocialMediaPopup(socialMedia: optionalSocialMediaInputs[indexPath.item - requiredSocialMediaInputs.count])
        }
    }
    
    //# MARK: - Setup Views
    
    func setupCollectionView() {
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(SocialMediaSelectedCell.self, forCellWithReuseIdentifier: socialMediaSelectedCellId)
        collectionView?.register(SocialMediaSelectionCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: socialMediaSelectionCellId)
        collectionView?.backgroundColor = UIColor.white
    }
    
    func setupNavBarButton() {
        let cancelButton = UIBarButtonItem.init(title: "cancel", style: .plain, target: self, action: #selector(cancelClicked))
        let nextButton = UIBarButtonItem.init(title: "next", style: .plain, target: self, action: #selector(nextClicked))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nextButton
    }
    
    func cancelClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentSocialMediaPopup(socialMedia: SocialMedia) {
        let socialMediaController = SocialMediaController()
        socialMediaController.socialMedia = socialMedia
        socialMediaController.newCardControllerDelegate = self
        socialMediaController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        navigationController?.definesPresentationContext = true
        navigationController?.present(socialMediaController, animated: false)
    }
    
    //# Mark: - Stored Info
    
    // For adding it to the collection view.
    func addSocialMediaInput(socialMedia: SocialMedia) {
        // TODO: Valid name checker. 
        // i.e. no blank usernames.
        if socialMedia.inputName != "" && socialMedia.isSet == false {
            socialMedia.isSet = true
            optionalSocialMediaInputs.append(SocialMedia(copyFrom: socialMedia))
        }
        collectionView?.reloadData()
    }
    
    // For adding it to the coredata
    func nextClicked() {
        requiredSocialMediaInputs.append(contentsOf: optionalSocialMediaInputs)
        requiredSocialMediaInputs.sort(by: { $0.name! < $1.name! })
        
        
        var concantenatedSocialMediaInputs: [(socialMediaName: String, inputName: String)] = []
        
        var currentSocialMediaName: String = ""
        for eachSocialInput in requiredSocialMediaInputs {
            if eachSocialInput.name == currentSocialMediaName {
                concantenatedSocialMediaInputs[(concantenatedSocialMediaInputs.count)-1].inputName = concantenatedSocialMediaInputs[(concantenatedSocialMediaInputs.count)-1].inputName + ", \(eachSocialInput.inputName!)"
            } else {
                currentSocialMediaName = eachSocialInput.name!
                concantenatedSocialMediaInputs.append((eachSocialInput.name!, eachSocialInput.inputName!))
                print(concantenatedSocialMediaInputs.count)
            }
        }
        
        var toSaveCard: JSON = [:]
        for eachConcantenatedSocialMediaInput in concantenatedSocialMediaInputs {
            let currentSocialMediaName = UIManager.makeShortHandForQR(eachConcantenatedSocialMediaInput.socialMediaName)
            toSaveCard[currentSocialMediaName!].string = eachConcantenatedSocialMediaInput.inputName
        }
        
        UserProfile.saveProfile(toSaveCard, forProfile: .myUser)
        userControllerDelegate?.reloadCard()
    }
}
