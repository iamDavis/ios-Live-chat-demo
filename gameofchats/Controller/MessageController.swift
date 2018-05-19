//
//  ViewController.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import UIKit
import Firebase
class MessageController: UITableViewController {
    let cellId = "cellId"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLogin()
        
        tableView.register(userCell.self, forCellReuseIdentifier: cellId)
    //    observeMessages()
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeMessages(){
    let ref = Database.database().reference().child("messages")
    ref.observe(.childAdded, with: { (snapshot) in
        print (snapshot)
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let message = Message()
            message.setValuesForKeys(dictionary)
            self.messages.append(message)
            
        }
    }, withCancel: nil)
 
    }
    
    @objc func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            
            let messageID = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageID)
            
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let message = Message()
                    let toId = dictionary["toId"] as? String ?? "toId not found"
                    let timestamp = dictionary["timestamp"] as? NSNumber?
                    let fromID = dictionary["fromId"] as? String ?? "fromID not found"
                    let text = dictionary["text"] as? String ?? "text not found"
                    print(dictionary)

                    message.toId = toId
                    message.timestamp = timestamp!
                    message.fromId = fromID
                    message.text = text
//                    message.setValuesForKeys(dictionary)
//                    self.messages.append(message)
                    
                    if let chatPartnerId = message.chatPartnerId(){
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array( self.messagesDictionary.values)
                        
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return (m1.timestamp?.intValue)! > (m2.timestamp?.intValue)!
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]

    guard let chatPartnerId = message.chatPartnerId() else {
        return
    }
    let ref = Database.database().reference().child("usrs").child(chatPartnerId)
    ref.observeSingleEvent(of: .value, with: {(snapshot) in
        print(snapshot)
        guard let dictionary = snapshot.value as? [String: AnyObject]
            else {
                return
        }
        let user = Usrs()
//        user.setValuesForKeys(dictionary)
        user.id = chatPartnerId
        let name = dictionary["name"] as? String ?? "Name not found"
        let ImageUrl = dictionary["profileImageUrl"] as? String ?? "Image not found"
        user.name = name
        user.profileImageUrl = ImageUrl
        self.setupNavBarWithUser(user: user)
        self.showChatController(user: user)
    }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! userCell
        
        let message = messages[indexPath.row]
        
        if let toId = message.toId {
            let ref = Database.database().reference().child("usrs").child(toId)
            ref.observe(DataEventType.value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    cell.textLabel?.text = dictionary["name"] as? String
//                    if let profileImageUrl = dictionary[]
                }
               // print(snapshot)
            }, withCancel: nil)
        }
        
        cell.message = message
        
        return cell
    }
    
    @objc func handleNewMessage(){
        let newMessageController = newMessagesController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    func checkIfUserIsLogin(){
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
        fetchUserAndSetupNavBarTitle()
        }
    }
    
 @objc   func fetchUserAndSetupNavBarTitle(){
        
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("usrs").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                print("process finished")
                
                let user = Usrs()
                let name = dictionary["name"] as? String ?? "Name not found"
                let ImageUrl = dictionary["profileImageUrl"] as? String ?? "Image not found"
                user.name = name
                user.profileImageUrl = ImageUrl
                self.setupNavBarWithUser(user: user)
                
            }
            
        }, withCancel: nil)
        
    }
    func setupNavBarWithUser(user: Usrs){
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIButton()
        
        titleView.frame = CGRect(x:0,y:0,width: 200
            , height: 40)
       // titleView.backgroundColor = UIColor.red
        
        
        
       
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        
        
        
        if let profileImageUrl = user.profileImageUrl{
        profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        }

        titleView.addSubview(profileImageView)
        //constrains
       // titleView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
       // titleView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        titleView.addSubview(nameLabel)

        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //constrains
        nameLabel.leftAnchor.constraintEqualToSystemSpacingAfter(profileImageView.rightAnchor, multiplier: 2).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView

   //     titleView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(showChatController)))
        
    }
    
    @objc func showChatController(user: Usrs){
        //let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    
    @objc func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        }   catch let logoutError{
            print(logoutError)
        }

    let loginController = LoginController()
        loginController.messageController = self
    present(loginController, animated: true, completion: nil)
    }
}

