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
import Firebase


typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> (Void)

protocol SpeechRecognitionServiceProtocol {
  func didReceiveAudioInputResponse(response: StreamingRecognizeResponse?, error: NSError?)
}


class SpeechRecognitionService {
  var sampleRate: Int = 16000
  private var streaming = false

  private var client : Speech!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!
  var delegate: SpeechRecognitionServiceProtocol?
  var audioData: Data?

  static let sharedInstance = SpeechRecognitionService()

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

  @objc func streamAudioData() {
    getDeviceID { (deviceID) in
      // authenticate using an authorization token (obtained using OAuth)
      FCMTokenProvider.getToken(deviceID: deviceID) { (shouldWait, token, error) in
        if let authT = token, shouldWait == false {//Token received execute code
          if (!self.streaming) {
            // if we aren't already streaming, set up a gRPC connection
            self.client = Speech(host: ApplicationConstants.STT_Host)
            self.writer = GRXBufferedPipe()
            self.call = self.client.rpcToStreamingRecognize(withRequestsWriter: self.writer,
                                                            eventHandler:
              { (done, response, error) in
                //completion(response, error as NSError?)
                self.delegate?.didReceiveAudioInputResponse(response: response, error: error as NSError?)
            })
            self.call.requestHeaders.setObject(NSString(string:authT), forKey:NSString(string:"Authorization"))
            // if the API key has a bundle ID restriction, specify the bundle ID like this
            self.call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!),
                                               forKey:NSString(string:"X-Ios-Bundle-Identifier"))
            print("HEADERS:\(String(describing: self.call.requestHeaders))")
            self.call.start()
            self.streaming = true
            // send an initial request message to configure the service
            let recognitionConfig = RecognitionConfig()
            recognitionConfig.encoding =  .linear16
            recognitionConfig.sampleRateHertz = Int32(self.sampleRate)
            recognitionConfig.languageCode = "en-US"
            recognitionConfig.maxAlternatives = 30
            recognitionConfig.enableWordTimeOffsets = true

            if let userPreference = UserDefaults.standard.value(forKey: ApplicationConstants.useerLanguagePreferences) as? [String: String] {
              let selectedTransFrom = userPreference[ApplicationConstants.selectedTransFrom] ?? ""
              if let appdelegate = UIApplication.shared.delegate as? AppDelegate,
                let voiceList = appdelegate.voiceLists {
                let transFrom = voiceList.filter {
                  return $0.languageName == selectedTransFrom
                }
                if let transFrom = transFrom.first {
                  let transFromLangCode =  transFrom.languageCode
                  recognitionConfig.languageCode = transFromLangCode
                }
              }
            }

            //Creating streamingRecognizeRequest
            let streamingRecognitionConfig = StreamingRecognitionConfig()
            streamingRecognitionConfig.config = recognitionConfig
            streamingRecognitionConfig.singleUtterance = false
            streamingRecognitionConfig.interimResults = true

            let streamingRecognizeRequest = StreamingRecognizeRequest()
            streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig

            self.writer.writeValue(streamingRecognizeRequest)
            //Remove notification
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(ApplicationConstants.tokenReceived), object: nil)
          }

          // send a request message containing the audio data
          let streamingRecognizeRequest = StreamingRecognizeRequest()
          streamingRecognizeRequest.audioContent = self.audioData ?? Data()
          self.writer.writeValue(streamingRecognizeRequest)
        } else if shouldWait == true {//Token will be sent via PN.
          //Observe for notification
          NotificationCenter.default.addObserver(self, selector: #selector(self.streamAudioData), name: NSNotification.Name(ApplicationConstants.tokenReceived), object: nil)
        }else {// an error occurred
          //Handle error
        }
      }
    }
  }

  func stopStreaming() {
    if (!streaming) {
      return
    }
    writer.finishWithError(nil)
    streaming = false
  }

  func isStreaming() -> Bool {
    return streaming
  }

}



