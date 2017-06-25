//
//  FamiliarizeCell.swift
//  familiarize
//
//  Created by Alex Oh on 6/1/17.
//  Copyright © 2017 nosleep. All rights reserved.
//

import QRCode
import SwiftyJSON
import UIKit

// You need to convert the JSON string to a data and then intialize it to create a json object! 


class FamiliarizeCell: BaseCell {
    var socialMediaButtons: [String : UIButton]?
    var onQRImage: Bool = true
    func createJSON() -> String {
        let qrJSON: JSON = [
            "name": "Alex Oh",
            "fb": "alexswoh",
            "ig": "alexswo",
            "sc": "alexoooh",
            "pn": "2136041187",
            "bio": "Software Engineer",
            ]
        return qrJSON.rawString()!
    }
    
    lazy var qrImageView: UIImageView = {
        var qrCode = QRCode(self.createJSON())
        qrCode?.color = CIColor.white()
        qrCode?.backgroundColor = CIColor(red:1.00, green: 0.52, blue: 0.52, alpha: 1.0)
        let imageView = UIImageView()
        imageView.image = qrCode?.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var cardBorder: UIImageView = {
        
        let image = UIManager.makeImage(imageName: "dan_card_border")
        image.tag = 1
        return image
    }()
    
    
    let bioLabel: UILabel = {
        let label = UIManager.makeLabel(numberOfLines: 1)
        return label
        
    }()
    
    func flip() {
        
        for v in (self.subviews){
            if v.tag != 1 {
                v.removeFromSuperview()
            }
        }
        if onQRImage == true {
            addSubview(bioLabel)
            
            let bio = NSMutableAttributedString(string: "Palo Alto, 29, Coffee Enthusiast", attributes: [NSFontAttributeName: UIFont(name: "Avenir", size: 20)!, NSForegroundColorAttributeName: UIColor(red:1.00, green: 0.52, blue: 0.52, alpha: 1.0)])
            
            bioLabel.attributedText = bio
            
            bioLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            bioLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30).isActive = true
            bioLabel.heightAnchor.constraint(equalToConstant: bioLabel.intrinsicContentSize.height).isActive = true
            bioLabel.widthAnchor.constraint(equalToConstant:bioLabel.intrinsicContentSize.width).isActive = true
            createSocialMediaButtons()
            presentSocialMediaButtons()
            
            onQRImage = false
        } else {
            addSubview(qrImageView)
            qrImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            qrImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 50).isActive = true
            qrImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            qrImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            onQRImage = true
        }
        
    }
    
    override func setupViews() {
        addSubview(cardBorder)
        addSubview(qrImageView)
        qrImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        qrImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 50).isActive = true
        qrImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        qrImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cardBorder.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        cardBorder.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 50).isActive = true
        cardBorder.heightAnchor.constraint(equalToConstant: 350).isActive = true
        cardBorder.widthAnchor.constraint(equalToConstant: 350).isActive = true
    }
    
    
    func buttonLink(_ userURL: String) {
        
        // Lmao, in order to get profile id, just scrape the facebook page again.
        // <meta property="al:ios:url" content="fb://profile/100001667117543">
        
        let fbURL = URL(string: "fb://profile?id=100001667117543")!
        
        let safariFBURL = URL(string: "https://www.facebook.com/100001667117543")!
        
        if UIApplication.shared.canOpenURL(fbURL)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fbURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(fbURL)
            }
            
        } else {
            //redirect to safari because the user doesn't have facebook application
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(safariFBURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(safariFBURL)
            }
        }
    }
    
    func didSelectFB() {
        buttonLink("Kabooya")
    }
    
    func didSelectIG() {
        buttonLink("Kabooya")
    }
    
    func didSelectSC() {
        buttonLink("Kabooya")
    }
    
    func didSelectPN() {
        buttonLink("Kabooya")
    }
    
    
    // FYI the button should be a facebook button
    lazy var fbButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_facebook_red")
        button.addTarget(self, action: #selector(didSelectFB), for: .touchUpInside)
        return button
    }()
    
    lazy var igButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_instagram_red")
        button.addTarget(self, action: #selector(didSelectIG), for: .touchUpInside)
        return button
    }()
    
    lazy var scButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_snapchat_red")
        button.addTarget(self, action: #selector(didSelectSC), for: .touchUpInside)
        return button
    }()
    
    lazy var pnButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_phone_red")
        button.addTarget(self, action: #selector(didSelectPN), for: .touchUpInside)
        return button
    }()
    
    lazy var inButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_linkedin_red")
        button.addTarget(self, action: #selector(didSelectFB), for: .touchUpInside)
        return button
    }()
    
    lazy var emButton: UIButton = {
        let button = UIManager.makeButton(imageName: "dan_email_red")
        button.addTarget(self, action: #selector(didSelectFB), for: .touchUpInside)
        return button
    }()
    
    func createSocialMediaButtons() {
        socialMediaButtons = [
            "fb": fbButton,
            "ig": igButton,
            "sc": scButton,
            "pn": pnButton,
            "in": inButton,
            "em": emButton,
        ]
    }
    
    let socialMedia = [
        "faceBookProfile": "fb",
        "instagramProfile": "ig",
        "snapChatProfile": "sc" ,
        "phoneNumber": "pn",
        "linkedin": "in",
        "email": "em",
        ]
    
    func presentSocialMediaButtons() {
 
        
        var spacing: CGFloat = 20
        for (_, button) in socialMediaButtons! {
            self.addSubview(button)
            button.topAnchor.constraint(equalTo: bioLabel.topAnchor, constant: 20).isActive = true
            button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacing).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            spacing += 60
        }
        
    }
    
    
}
