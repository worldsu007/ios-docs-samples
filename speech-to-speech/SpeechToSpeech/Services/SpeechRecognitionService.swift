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


typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> (Void)

class SpeechRecognitionService {
  var sampleRate: Int = 16000
  private var streaming = false
  
  private var client : Speech!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!
  
  static let sharedInstance = SpeechRecognitionService()
  
  private let tokenService = TokenService.shared
  
  func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
    tokenService.authorization(completionHandler: { (authT) in
      if (!self.streaming) {
        // if we aren't already streaming, set up a gRPC connection
        self.client = Speech(host: ApplicationConstants.STT_Host)
        self.writer = GRXBufferedPipe()
        self.call = self.client.rpcToStreamingRecognize(withRequestsWriter: self.writer,
                                                        eventHandler:
          { (done, response, error) in
            completion(response, error as NSError?)
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

        
        let streamingRecognitionConfig = StreamingRecognitionConfig()
        streamingRecognitionConfig.config = recognitionConfig
        streamingRecognitionConfig.singleUtterance = false
        streamingRecognitionConfig.interimResults = true
        
        let streamingRecognizeRequest = StreamingRecognizeRequest()
        streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig
        
        self.writer.writeValue(streamingRecognizeRequest)
      }
      
      // send a request message containing the audio data
      let streamingRecognizeRequest = StreamingRecognizeRequest()
      streamingRecognizeRequest.audioContent = audioData as Data
      self.writer.writeValue(streamingRecognizeRequest)
    })
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

