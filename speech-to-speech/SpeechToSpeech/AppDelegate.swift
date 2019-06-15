//
// Copyright 2019 Google Inc. All Rights Reserved.
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  var voiceLists: [FormattedVoice]?
  
  func application
    (_ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)
    -> Bool {
      TextToSpeechRecognitionService.sharedInstance.getVoiceLists { (formatedVoices, errorString) in
        if let errorString = errorString {
          let alertVC = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
          alertVC.addAction(UIAlertAction(title: "OK", style: .default))
          self.window?.rootViewController?.present(alertVC, animated: true)
        }
        self.voiceLists = formatedVoices
      }
      return true
  }
}
