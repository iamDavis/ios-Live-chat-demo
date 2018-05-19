//
//  newMessagesController.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import UIKit
import Firebase
class newMessagesController: UITableViewController {
    let cellID = "cellID"
    var usrs = [Usrs]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem (title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(userCell.self, forCellReuseIdentifier: cellID)
        fetchUsers()
        
}
    func fetchUsers() {
        let rootRef = Database.database().reference()
        let query = rootRef.child("usrs").queryOrdered(byChild: "name")
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let key = child.key
                if let value = child.value as? NSDictionary {
                    let user = Usrs()
                    user.id = key
                    
                    let name = value["name"] as? String ?? "Name not found"
                    let email = value["email"] as? String ?? "Email not found"
                    let profileImageUrl = value["profileImageUrl"] as? String ?? "Profile Image not found"
                    user.name = name
                    user.email = email
                    user.profileImageUrl = profileImageUrl
                 //   print(user.name, user.email)
                    
                    self.usrs.append(user)
                    
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
    }
   @objc func handleCancel(){
        dismiss(animated: true , completion: nil)
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usrs.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // use a hack for nowe
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! userCell
        let user = usrs[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.imageView?.contentMode = .scaleAspectFill
    
        
        if let profileImageUrl = user.profileImageUrl{
            print("Image")
            
            cell.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        /*    let url = URL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, Error) in
                if Error != nil {
                    print(Error)
                    return
                }
                    DispatchQueue.main.async {
                        cell.profileImageView.image = UIImage(data:data!)
                        print("Image fetched")
                }
               
            }).resume() */
            
        }
       
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    var messagesController : MessageController?

    override func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.usrs[indexPath.row]
            self.messagesController?.showChatController(user: user)
        }
    }
}


