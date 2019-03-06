//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit
import FirebaseFunctions
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var hasRequestedForToken = false
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey :Any]? = nil) -> Bool {
    FirebaseApp.configure()
    generateAccessToken()
    return true
  }
  
  func generateAccessToken() {
    //Block the UI/ show a pop up message / a diff screen
    Auth.auth().signInAnonymously() { (authResult, error) in let user = authResult?.user
      guard let uid = user?.uid else {
        return
      }
      print("UID: \(uid)")
      TokenReceiver.sharedInstance.retrieveAccessTokenFor(uid: uid, completionHandler: {(token, error) in
        if token != nil {
          StopwatchService.sharedInstance.token = token!
          NotificationCenter.default.post(name: NSNotification.Name("TokenReceived"), object: nil)
        }
      })
    }
  }
}
