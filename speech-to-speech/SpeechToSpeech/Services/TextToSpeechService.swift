//
// Copyright 2019 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License")
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

protocol VoiceListProtocol {
  func didReceiveVoiceList(voiceList: [FormattedVoice]?, errorString: String?)
}

class TextToSpeechRecognitionService {
  var client = TextToSpeech(host: ApplicationConstants.TTS_Host)
  private var writer = GRXBufferedPipe()
  private var call : GRPCProtoCall!
  
  static let sharedInstance = TextToSpeechRecognitionService()
  var voiceListDelegate: VoiceListProtocol?
  
  func getDeviceID(callBack: @escaping (String)->Void) {
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("Error fetching remote instance ID: \(error)")
        callBack( "")
      } else if let result = result {
        print("Remote instance ID token: \(result.token)")
        callBack( result.token)
      } else {
        callBack( "")
      }
    }
  }
  
  func textToSpeech(text:String, completionHandler: @escaping (_ audioData: Data?, _ error: String?) -> Void) {
    let authT = FCMTokenProvider.getTokenFromUserDefaults()
    let synthesisInput = SynthesisInput()
    synthesisInput.text = text
    
    let voiceSelectionParams = VoiceSelectionParams()
    voiceSelectionParams.languageCode = "en-US"
    //voiceSelectionParams.ssmlGender = SsmlVoiceGender.neutral
    
    if let userPreference = UserDefaults.standard.value(forKey: ApplicationConstants.useerLanguagePreferences) as? [String: String] {
      let selectedTransTo = userPreference[ApplicationConstants.selectedTransTo] ?? ""
      let selectedSynthName = userPreference[ApplicationConstants.selectedSynthName] ?? ""
      let selectedVoiceType = userPreference[ApplicationConstants.selectedVoiceType] ?? ""
      
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let voiceList = appDelegate.voiceLists {
        let transTo = voiceList.filter {
          return $0.languageName == selectedTransTo
        }
        if let transTo = transTo.first {
          let transToLangCode =  transTo.languageCode
          voiceSelectionParams.languageCode = transToLangCode
          
          if let synthNameIndex = transTo.synthesisName.index(of: selectedSynthName){
            let synthNameCode = transTo.synthesisNameCode[synthNameIndex]
            voiceSelectionParams.name = synthNameCode
          }
          if let synthGenderIndex = transTo.synthesisGender.index(of: selectedVoiceType){
            let synthGenderCode = transTo.synthesisGenderCode[synthGenderIndex]
            voiceSelectionParams.ssmlGender = synthGenderCode
          }
        }
      }
    }
    
    let audioConfig = AudioConfig()
    audioConfig.audioEncoding = AudioEncoding.mp3
    
    let speechRequest = SynthesizeSpeechRequest()
    speechRequest.audioConfig = audioConfig
    speechRequest.input = synthesisInput
    speechRequest.voice = voiceSelectionParams
    
    self.call = self.client.rpcToSynthesizeSpeech(with: speechRequest, handler: { (synthesizeSpeechResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        completionHandler(nil, error?.localizedDescription )
        return
      }
      guard let response = synthesizeSpeechResponse else {
        print("No response received")
        return
      }
      print("Text to speech response\(response)")
      guard let audioData =  response.audioContent else {
        print("no audio data received")
        return
      }
      completionHandler(audioData, nil)
    })
    
    self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
    // if the API key has a bundle ID restriction, specify the bundle ID like this
    self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
    print("HEADERS:\(String(describing: self.call.requestHeaders))")
    self.call.start()
  }
  
  @objc func getVoiceLists() {
    SpeechRecognitionService.sharedInstance.getDeviceID { (deviceID) in
      FCMTokenProvider.getToken(deviceID: deviceID, { (shouldWait, token, error) in
        if let authT = token, shouldWait == false {//Token received execute code
          self.call = self.client.rpcToListVoices(with: ListVoicesRequest(), handler: { (listVoiceResponse, error) in
            if let errorStr = error?.localizedDescription {
              self.voiceListDelegate?.didReceiveVoiceList(voiceList: nil, errorString: errorStr)
              //                        completionHandler(nil, errorStr)
              return
            }
            print(listVoiceResponse ?? "No voice list found")
            if let listVoiceResponse = listVoiceResponse {
              let formattedVoice = FormattedVoice.formatVoiceResponse(listVoiceResponse: listVoiceResponse)
              self.voiceListDelegate?.didReceiveVoiceList(voiceList: formattedVoice, errorString: nil)
              //                        completionHandler(formattedVoice, nil)
            }
          })
          self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
          // if the API key has a bundle ID restriction, specify the bundle ID like this
          self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
          print("HEADERS:\(String(describing: self.call.requestHeaders))")
          self.call.start()
        } else if shouldWait == true {//Token will be sent via PN.
          //Observe for notification
          NotificationCenter.default.addObserver(self, selector: #selector(self.getVoiceLists), name: NSNotification.Name(ApplicationConstants.tokenReceived), object: nil)
        } else {// an error occurred
          //Handle error
        }
      })
    }
  }
}

struct FormattedVoice {
  var languageCode: String = ""
  var languageName: String = ""
  var synthesisName: [String] = []
  var synthesisGender: [String] = []
  var synthesisNameCode: [String] = []
  var synthesisGenderCode: [SsmlVoiceGender] = []
  
  static func formatVoiceResponse(listVoiceResponse: ListVoicesResponse) -> [FormattedVoice] {
    var result = [FormattedVoice]()
    for voice in listVoiceResponse.voicesArray {
      if let voice = voice as? Voice {
        for languageCode in voice.languageCodesArray {
          let index = result.filter({$0.languageCode == ((languageCode as? String) ?? "")})
          var resultVoice = index.count > 0 ? (index.first ?? FormattedVoice()) : FormattedVoice()
          resultVoice.languageCode = (languageCode as? String) ?? ""
          resultVoice.languageName = convertLanguageCodes(languageCode: resultVoice.languageCode)
          
          let name = getSynthesisName(name: voice.name)
          if !resultVoice.synthesisName.contains(name) {
            resultVoice.synthesisName.append(getSynthesisName(name: voice.name))
            resultVoice.synthesisNameCode.append(voice.name)
          }
          
          let gender = getGender(name: voice.name, gender: voice.ssmlGender)
          if !resultVoice.synthesisGender.contains(gender) {
            resultVoice.synthesisGender.append(gender)
            resultVoice.synthesisGenderCode.append(voice.ssmlGender)
          }
          if index.count > 0 {
            
            result.removeAll(where: {$0.languageCode == ((languageCode as? String) ?? "")})
          }
          result.append(resultVoice)
        }
      }
    }
    result = result.sorted(by: {$0.languageName.uppercased() < $1.languageName.uppercased()})
    
    return result
  }
  
  static func convertLanguageCodes(languageCode: String) -> String {
    var languageName = ""
    switch (languageCode) {
    case "da-DK":
      languageName = "Danish"
    case "de-DE":
      languageName = "German"
    case "en-AU":
      languageName = "English AU"
    case "en-GB":
      languageName = "English UK"
    case "en-US":
      languageName = "English US"
    case "es-ES":
      languageName = "Spanish"
    case "fr-CA":
      languageName = "French CA"
    case "fr-FR":
      languageName = "French"
    case "it-IT":
      languageName = "Italian"
    case "ja-JP":
      languageName = "Japanese"
    case "ko-KR":
      languageName = "Korean"
    case "nl-NL":
      languageName = "Dutch"
    case "nb-NO":
      languageName = "Norwegian"
    case "pl-PL":
      languageName = "Polish"
    case "pt-BR":
      languageName = "Portugese BR"
      
    case "pt-PT":
      languageName = "Portugese"
      
    case "ru-RU":
      languageName = "Russian"
      
    case "sk-SK":
      languageName = "Slovak SK"
      
    case "sv-SE":
      languageName = "Swedish"
      
    case "tr-TR":
      languageName = "Turkish"
      
    case "uk-UA":
      languageName = "Ukrainian UA"
      
    default:
      languageName = languageCode
    }
    return "\(languageName) (\(languageCode))"
  }
  
  static func getSynthesisName(name: String) -> String {
    let components = name.components(separatedBy: "-")
    if components.count > 2 {
      return components[2]
    }
    return ""
  }
  
  static func getGender(name: String, gender: SsmlVoiceGender) -> String {
    let components = name.components(separatedBy: "-")
    if components.count > 3 {
      return gender.getGenderString() + " " + components[3]
    }
    return gender.getGenderString()
  }
}

extension SsmlVoiceGender {
  func getGenderString() -> String {
    switch self {
    case .gpbUnrecognizedEnumeratorValue:
      return "Unspecified"
    case .ssmlVoiceGenderUnspecified:
      return "Unspecified"
    case .male:
      return "Male"
    case .female:
      return "Female"
    case .neutral:
      return "Neutral"
    }
  }
}



