//
//  AuthenticationObserver.swift
//  Project342
//
//  Created by Zhe Xian Lee on 04/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationObserver {
    
    static let observer = AuthenticationObserver()
    
    var eventHandler: FIRAuthStateDidChangeListenerHandle?
    
    func observeAuthenticationEvent() {
        eventHandler = FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if user != nil {
                MessageObserver.observer.observeMessageEvents()
                ConversationObserver.observer.observeConversationEvents()
                ConversationObserver.observer.observeConversationMemberEvents()
                ContactObserver.observer.observeContactsEvents()
            }
        })
    }
    
    func stopObservingAuthenticationEvent() {
        guard
            let eventHandler = eventHandler
            else {
                return
        }
        
        FIRAuth.auth()?.removeAuthStateDidChangeListener(eventHandler)
        
        MessageObserver.observer.stopObservingMessageEvents()
        ConversationObserver.observer.stopObservingConversationEvents()
        ConversationObserver.observer.stopObservingConversationEvents()
        ContactObserver.observer.stopObservingContactsEvents()

    }
    
}

