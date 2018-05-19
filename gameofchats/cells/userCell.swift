//
//  userCell.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import UIKit
import Firebase
class userCell: UITableViewCell{
    
    var message: Message? {
        didSet{
            
            setUpNameAndAvetar()
            
           
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue{
            
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            timeLabel.text = timestampDate.description
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                
            }
        }
    }
    
    let timeLabel: UILabel = {
       let label = UILabel()
//        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x:80,y:textLabel!.frame.origin.y-2,width:textLabel!.frame.width,height:textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x:80,y:detailTextLabel!.frame.origin.y+2,width:detailTextLabel!.frame.width,height:detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 33.75
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        //constraint anchors for imageView
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo:self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 67.5).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 67.5).isActive = true
        
        //constraint anchors for time
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(Coder:) has not been implemented")
    }
    
    private func setUpNameAndAvetar(){
//        print ("test: ",  message?.text)
//        print ("chatPatenerId" + chatPatenerId!)
        
        if let Id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("usrs").child(Id)
            ref.observe(.value, with: { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl =  dictionary["profileImageUrl"]as? String{
                        self.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
}

