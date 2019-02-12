//
//  TokenGenerator.swift
//  Stopwatch
//
//  Created by Santhosh Vaddi on 2/8/19.
//  Copyright © 2019 Google. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class TokenGenerator {
    
    var snapshotListener: ListenerRegistration!
    static let sharedInstance = TokenGenerator()
    
    func retrieveAccessTokenFor(uid: String) {
        let docRef =  Firestore.firestore().collection("users").document(uid)
        snapshotListener = docRef.addSnapshotListener(includeMetadataChanges: true, listener: { (snapShot, error) in
            guard let tokenDict = snapShot?.data(), let accessTokenDict = tokenDict["token"] as? [String: Any], let accessToken = accessTokenDict["accessToken"] as? String, let expiryDate = accessTokenDict["expireTime"] as? String else {
                print( "some error occurred")
                //This user is not having accesstoken mostly.
                //This will execute the index.js to generate.
                self.requestAccessTokenFor(uid: uid)
                //index.js will generate accesstoken and save in the database.
                return
            }
            //if token received from the database expired then request index.js to generate new token.
            //Else good to use the token for dialogflow services
            if self.isExpired(expDate: expiryDate) {
                self.requestAccessTokenFor(uid: uid)
            }else {
                print("**********Token**********\(accessToken)")
                StopwatchService.sharedInstance.token = accessToken
            }
        })
    }
    
    func isExpired(expDate: String) -> Bool {
        var expired = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let expiryDate = dateFormatter.date(from: expDate) else {return expired}
        expired = (Date() > expiryDate)
        return expired
    }
    
    func requestAccessTokenFor(uid: String) {
        Functions.functions().httpsCallable("getToken").call() { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print(code ?? "")
                    print(message)
                    print(details ?? "")
                }
            }
            self.retrieveAccessTokenFor(uid: uid)
        }
    }
}
