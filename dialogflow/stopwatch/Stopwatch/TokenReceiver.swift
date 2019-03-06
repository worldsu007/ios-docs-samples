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

import Foundation
import Firebase

class TokenReceiver {

  public static let sharedInstance = TokenReceiver()
  public func retrieveAccessTokenFor(uid: String, completionHandler: @escaping (String?, Error?) -> Void) {
    Functions.functions().httpsCallable("getOAuthToken").call { (result, error) in
      if error != nil {
        print("error description \(error?.localizedDescription ?? "no description available")")
        completionHandler(nil, error)
        return
      }
      guard let res: HTTPSCallableResult = result else {
        print("result found nil")
        completionHandler(nil, "Result found nil" as? Error)
        return
      }
      guard let tokenData = res.data as? [String: Any] else {return}
      if let accessToken = tokenData["accessToken"] as? String, !accessToken.isEmpty {
        completionHandler(accessToken, nil)
      }
      print("result = \(String(describing: tokenData))")
    }
  }

}
