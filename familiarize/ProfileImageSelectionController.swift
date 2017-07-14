//
//  ProfileImageSelectionController.swift
//  familiarize
//
//  Created by Alex Oh on 7/13/17.
//  Copyright © 2017 nosleep. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class ProfileImageSelectionController: UICollectionViewController {
    
    private let cellId = "cellId"
    
    var socialMediaProfileImages: [SocialMediaProfileImage]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    let selectProfileInstruction: UILabel = {
        let label = UIManager.makeLabel(numberOfLines: 1)
        label.text = "Select profile image"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupViews()
    }
    
    func setupCollectionView() {
        self.collectionView?.backgroundColor = UIColor.white
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.scrollDirection = .horizontal
        collectionView?.collectionViewLayout = layout
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(ProfileImageSelectionCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        view.addSubview(selectProfileInstruction)
        selectProfileInstruction.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectProfileInstruction.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        selectProfileInstruction.widthAnchor.constraint(equalToConstant: selectProfileInstruction.intrinsicContentSize.width).isActive = true
        selectProfileInstruction.heightAnchor.constraint(equalToConstant: selectProfileInstruction.intrinsicContentSize.height).isActive = true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = socialMediaProfileImages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! ProfileImageSelectionCell
        
        if let socialMediaProfileImage = socialMediaProfileImages?[indexPath.item] {
            cell.socialMediaProfileImage = socialMediaProfileImage
        }
        
        return cell
    }
    
    
 
    
}