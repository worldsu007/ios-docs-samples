//
//  TokenGenerator.swift
//  Stopwatch
//
//  Created by Santhosh Vaddi on 2/8/19.
//  Copyright © 2019 Google. All rights reserved.
//

import Foundation
import Firebase

class TokenGenerator {
  
  var snapshotListener: ListenerRegistration!
  static let sharedInstance = TokenGenerator()
  var hasRequestedForToken = false
  
  //This method searches for token in firestore for the given uid
  //If token is available, then it checks for token expiry date
  //If token is valid, it returns token to user passing it in completion handler
  //If token is expired, then it requests to generate new token
  func retrieveAccessTokenFor(uid: String) {
    let docRef =  Firestore.firestore().collection("users").document(uid)
    //Added a listener into database, for any modification into database, this will get notified.
    snapshotListener = docRef.addSnapshotListener(includeMetadataChanges: true, listener: { (snapShot, error) in
      guard let tokenDict = snapShot?.data(), let accessTokenDict = tokenDict["token"] as? [String: Any], let accessToken = accessTokenDict["accessToken"] as? String, let expiryDate = accessTokenDict["expireTime"] as? String else {
        print( "some error occurred")
        //This user is not having accesstoken mostly.
        if self.hasRequestedForToken == false{
          self.requestAccessTokenFor(uid: uid) //This will execute the index.js code.
          //index.js will generate accesstoken and save in the database.
          self.hasRequestedForToken = true
        }
        return
      }
      //if token received from the database expired then request index.js to generate new token.
      //Else good to use the token for dialogflow services
      if self.isExpired(expDate: expiryDate) {
        if self.hasRequestedForToken == false {
          self.requestAccessTokenFor(uid: uid)
          self.hasRequestedForToken = true
        }
        
      }else {
        print("**********Token**********\(accessToken)")
        StopwatchService.sharedInstance.token = accessToken
      }
    })
  }
  
  
  //This function compares token expiry date with current date
  //Returns bool value if token is expired else false
  func isExpired(expDate: String) -> Bool {
    var expired = true
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    guard let expiryDate = dateFormatter.date(from: expDate) else {return expired}
    expired = (Date() > expiryDate)
    return expired
  }
  
  
  //This function calls firebse function "gettoken" which was implemented in index.js
  //once it receives success callback, it calls retrieveAccessTokenFor function to get token from firestore
  //As "getToken" method will store newly generated token into database with uid key
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
