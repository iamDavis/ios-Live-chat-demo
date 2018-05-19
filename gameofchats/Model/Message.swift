//
//  Message.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
 
    func chatPartnerId() -> String? {
//        let chatPatenerId: String?
//        if message?.fromId == Auth.auth().currentUser?.uid {
//            //            print(message)
//            chatPatenerId = message?.toId
//            //            print(chatPatenerId)
//        }else {
//            chatPatenerId = message?.fromId
//            //            print(chatPatenerId)
//        }
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId

    }
}
