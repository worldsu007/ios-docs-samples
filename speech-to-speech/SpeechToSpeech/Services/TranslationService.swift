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
import googleapis
import AuthLibrary

enum ServiceError: Error {
  case unknownError
  case invalidCredentials
  case tokenNotAvailable

}

let TRANSLATE_HOST = "translation.googleapis.com"

typealias TranslationCompletionHandler = (TranslateTextResponse?, NSError?) -> (Void)

class TranslationServices {
  static let sharedInstance = TranslationServices()
  private var client = TranslationService(host: TRANSLATE_HOST)
  private var call : GRPCProtoCall!
  func translateText(text: String, completionHandler: @escaping (TranslateTextResponse?, String?)->Void) {
   try? FirebaseFunctionTokenProvider().withToken { (authT, error) in
      let translateRequest = TranslateTextRequest()
      if let userPreference = UserDefaults.standard.value(forKey: ApplicationConstants.useerLanguagePreferences) as? [String: String] {
        let selectedTransFrom = userPreference[ApplicationConstants.selectedTransFrom] ?? ""
        let selectedTransTo = userPreference[ApplicationConstants.selectedTransTo] ?? ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists {
          let transTo = voiceList.filter {
            return $0.languageName == selectedTransTo
          }
          if let transTo = transTo.first {
            let transToLangCode =  transTo.languageCode
            translateRequest.targetLanguageCode = transToLangCode
          }

          let transFrom = voiceList.filter {
            return $0.languageName == selectedTransFrom
          }
          if let transFrom = transFrom.first {
            let transFromLangCode =  transFrom.languageCode
            translateRequest.sourceLanguageCode = transFromLangCode
          }
        }
      }
      
      translateRequest.contentsArray = [text]
      translateRequest.mimeType = "text/plain"
      translateRequest.parent = ApplicationConstants.translateParent
      self.call = self.client.rpcToTranslateText(with: translateRequest, handler: { (translateResponse, error) in
        if error != nil {
          print(error?.localizedDescription ?? "No eror description found")
          completionHandler(nil, error?.localizedDescription)
          return
        }
        print(translateResponse ?? "Responsd found nil")
        guard let res = translateResponse else {return}
        completionHandler(res, nil)
      })
      self.call.requestHeaders.setObject(NSString(string:authT?.AccessToken ?? ""), forKey:NSString(string:"Authorization"))
      // if the API key has a bundle ID restriction, specify the bundle ID like this
      self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
      self.call.start()
    }
  }
}

