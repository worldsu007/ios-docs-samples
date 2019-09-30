//
// Copyright 2019 Google LLC
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
import AVFoundation
import AuthLibrary
import Firebase

class TextToTranslationService {
  private var client : TranslationService = TranslationService(host: ApplicationConstants.Host)
  private var writer : GRXBufferedPipe = GRXBufferedPipe()
  private var call : GRPCProtoCall!
  static let sharedInstance = TextToTranslationService()
  var authToken: String = ""

  func getDeviceID(callBack: @escaping (String)->Void) {
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("Error fetching remote instance ID: \(error)")
        callBack( "")
      } else if let result = result {
        print("Remove instance ID token: \(result.token)")
        callBack( result.token)
      } else {
        callBack( "")
      }
    }
  }
  
  func textToTranslate(text:String, completionHandler: @escaping (_ response: TranslateTextResponse?, _ errorText: String?) -> Void) {
    
    let translateText = TranslateTextRequest()
    translateText.contentsArray = [text]
    translateText.mimeType = ApplicationConstants.mimeType
    let sourceLanguageCode = UserDefaults.standard.value(forKey: ApplicationConstants.sourceLanguageCode) as? String
    let targetLanguageCode = UserDefaults.standard.value(forKey: ApplicationConstants.targetLanguageCode) as? String
    translateText.sourceLanguageCode = sourceLanguageCode ?? "en-US"
    translateText.targetLanguageCode = targetLanguageCode ?? "es"
    translateText.parent = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)"
    let glossaryStatus = UserDefaults.standard.bool(forKey: ApplicationConstants.glossaryStatus)
    if glossaryStatus {
      let glossaryConfig = TranslateTextGlossaryConfig()
      if let selectedGlossary = UserDefaults.standard.value(forKey: "SelectedGlossary") as? String {
        glossaryConfig.glossary = selectedGlossary
      } else {
        glossaryConfig.glossary = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)/glossaries/\(ApplicationConstants.glossaryID)"
      }
      
      glossaryConfig.ignoreCase = true
      translateText.glossaryConfig = glossaryConfig
    }
    call = client.rpcToTranslateText(with: translateText) { (translateTextResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        completionHandler(nil, error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = translateTextResponse else {
        print("No response received")
        completionHandler(nil, "No response received")
        return
      }
      print("translateTextResponse\(response)")
      completionHandler(response, nil)
    }
    self.call.requestHeaders.setObject(NSString(string:authToken),
                                       forKey:NSString(string:"Authorization"))
    self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
    call.start()
  }

  func getLanguageCodes(completionHandler: @escaping (_ response: SupportedLanguages?, _ errorText: String?) -> Void) {
    let langRequest = GetSupportedLanguagesRequest()
    langRequest.parent = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)"
    call = client.rpcToGetSupportedLanguages(with: langRequest, handler: { (supportedLanguagesResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        completionHandler(nil, error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = supportedLanguagesResponse else {
        print("No response received")
        completionHandler(nil, "No response received")
        return
      }
      print("supportedLanguagesResponse\(response)")
      completionHandler(response, nil)
    })
    self.call.requestHeaders.setObject(NSString(string:authToken),
                                       forKey:NSString(string:"Authorization"))

    self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
    call.start()
  }
  
  func getListOfGlossary(completionHandler: @escaping (_ response: ListGlossariesResponse?, _ errorText: String?) -> Void) {
    let glossaryRequest = ListGlossariesRequest()
    glossaryRequest.parent = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)"
    call = client.rpcToListGlossaries(with: glossaryRequest, handler: { (listGlossariesResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        completionHandler(nil, error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = listGlossariesResponse else {
        print("No response received")
        completionHandler(nil, "No response received")
        return
      }
      print("listGlossariesResponse\(response)")
      completionHandler(response, nil)
    })
    self.call.requestHeaders.setObject(NSString(string:authToken),
                                       forKey:NSString(string:"Authorization"))
    self.call.requestHeaders.setObject(NSString(string: Bundle.main.bundleIdentifier!),
                                       forKey: NSString(string: "X-Ios-Bundle-Identifier"))
    call.start()
  }

  func getGlossary(completionHandler: @escaping (_ response: ListGlossariesResponse) -> Void) {
    let glossaryRequest = GetGlossaryRequest()
    glossaryRequest.name = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)/glossaries/\(ApplicationConstants.glossaryID)"
    call = client.rpcToGetGlossary(with: glossaryRequest, handler: { (listGlossariesResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = listGlossariesResponse else {
        print("No response received")
        return
      }
      print("rpcToGetGlossary\(response)")
    })
    self.call.requestHeaders.setObject(NSString(string:authToken),
                                       forKey:NSString(string:"Authorization"))
    self.call.requestHeaders.setObject(NSString(string: Bundle.main.bundleIdentifier!),
                                       forKey: NSString(string: "X-Ios-Bundle-Identifier"))
    call.start()
  }
  
  //To create new glossary, go through https://cloud.google.com/translate/docs/glossary#create_a_glossary
  //To create from here update the ApplicationConstants.glossaryID, languageCodesArray, inputUri
  //Then call this function
  //To check the long running status, from the logs get the operation id and execute the curl command from this https://cloud.google.com/translate/docs/long-running-operation
  func createGlossary(completionHandler: @escaping (_ response: ListGlossariesResponse) -> Void) {
    let glossaryRequest = CreateGlossaryRequest()
    glossaryRequest.parent = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)"
    let glossary = Glossary()
    glossary.name = "projects/\(ApplicationConstants.projectID)/locations/\(ApplicationConstants.locationID)/glossaries/\(ApplicationConstants.glossaryID)"
    
    let languageCodeSet = Glossary_LanguageCodesSet()
    languageCodeSet.languageCodesArray = ["en", "en-GB", "ru", "fr", "pt-BR", "pt-PT", "es"]
    
    let glossaryConfig = GlossaryInputConfig()
    glossaryConfig.gcsSource.inputUri = "gs://bucket-name/glossary-filename"
    
    glossary.inputConfig = glossaryConfig
    glossary.languageCodesSet = languageCodeSet
    glossaryRequest.glossary = glossary
    
    call = client.rpcToCreateGlossary(with: glossaryRequest, handler: { (listGlossariesResponse, error) in //Operation
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = listGlossariesResponse else {
        print("No response received")
        return
      }
      print("rpcToGetGlossary\(response)")
    })
    self.call.requestHeaders.setObject(NSString(string:authToken),
                                       forKey:NSString(string:"Authorization"))
    self.call.requestHeaders.setObject(NSString(string: Bundle.main.bundleIdentifier!),
                                       forKey: NSString(string: "X-Ios-Bundle-Identifier"))
    call.start()
  }
}




