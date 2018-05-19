//
//  ChatLogController.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import  UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user : Usrs? {
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    
    
  lazy var  inputTextFiled: UITextField = {
        let TextFiled = UITextField()
        TextFiled.placeholder = "Enter message"
        TextFiled.translatesAutoresizingMaskIntoConstraints = false
        TextFiled.delegate = self
        return TextFiled
    }()
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupInputComponent()
        setupKeyboardObservers()
    }
    
//    lazy var inputContainerView: UIView = {
//        let containerView = UIView()
//        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
//        containerView.backgroundColor = UIColor.white
//
////        let textField = UITextField()
////        textField.placeholder = "ENTER SOME TEXT"
////        containerView.addSubview(textField)
////        textField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
//
//        let send = UIButton(type: .system)
//        send.setTitle("Send", for: .normal)
//        send.translatesAutoresizingMaskIntoConstraints = false
//        send.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//        containerView.addSubview(send)
//        //constrain
//        send.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        send.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        send.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        send.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//
//
//     /*     let inputTextFiled = UITextField()
//         inputTextFiled.placeholder = "Enter message"
//         inputTextFiled.translatesAutoresizingMaskIntoConstraints = false */
//        containerView.addSubview(self.inputTextFiled)
//        // constrain
//        self.inputTextFiled.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
//        self.inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        self.inputTextFiled.rightAnchor.constraint(equalTo: send.leftAnchor).isActive = true
//        self.inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//
//
//        let separatorLineView = UIView()
//        separatorLineView.backgroundColor = UIColor(r:220,g:220,b:220)
//        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(separatorLineView)
//        // constrain
//        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
//        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//
//        return containerView
//    }()
//
//    override var inputAccessoryView: UIView?{
//        get{
//            return inputContainerView
//        }
//}
//    override func becomeFirstResponder() -> Bool {
//          return true
//    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hanldeKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
//        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                _ = keyboardFrame.cgRectValue.height
            
                let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

            containerViewBottomAnchor?.constant = -keyboardFrame.cgRectValue.height
                UIView.animate(withDuration: keyboardDuration!) {
                    self.view.layoutIfNeeded()
                }
        }
    }
    
    @objc func hanldeKeyboardWillHide(notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    var messages = [Message]()

    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            print("testmid", messageId)
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print("test10000",snapshot)
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()
            
                let toId = dictionary["toId"] as? String ?? "toId not found"
                let timestamp = dictionary["timestamp"] as? NSNumber?
                let fromID = dictionary["fromId"] as? String ?? "fromID not found"
                let text = dictionary["text"] as? String ?? "text not found"
                message.toId = toId
                message.timestamp = timestamp!
                message.fromId = fromID
                message.text = text
                
                if message.chatPartnerId() == self.user?.id {
                     self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
               
                
              
            }, withCancel: nil)
        }, withCancel: nil)

    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    @objc   override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        }
        
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        }else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let  size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponent(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //constrains
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let send = UIButton(type: .system)
        send.setTitle("Send", for: .normal)
        send.translatesAutoresizingMaskIntoConstraints = false

        send.addTarget(self, action: #selector(handleSend), for: .touchUpInside)

        containerView.addSubview(send)
        //constrain

        send.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        send.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        send.widthAnchor.constraint(equalToConstant: 80).isActive = true
        send.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true


     /*   let inputTextFiled = UITextField()
        inputTextFiled.placeholder = "Enter message"
        inputTextFiled.translatesAutoresizingMaskIntoConstraints = false  */
        containerView.addSubview(inputTextFiled)
        // constrain
        inputTextFiled.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextFiled.rightAnchor.constraint(equalTo: send.leftAnchor).isActive = true
        inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true


        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r:220,g:220,b:220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        // constrain
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true

        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }
    
    
    @objc func handleSend(){
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser?.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))

        
        
        let values: [String : Any] = ["text":inputTextFiled.text!,"toId": toId ,"fromId": fromId as Any,"timestamp": timeStamp] 
        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            
            self.inputTextFiled.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId!)
            let messageID = childRef.key
            userMessageRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
        //这里有问题
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
