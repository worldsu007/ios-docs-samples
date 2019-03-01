//
// Copyright 2017 Google Inc. All Rights Reserved.
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

let Host = "dialogflow.googleapis.com"
let ProjectName = "your-project-identifier" // UPDATE THIS
let SessionID = "001"
let SampleRate = 16000

typealias StopwatchCompletionHandler =
  (DFStreamingDetectIntentResponse?, NSError?) -> (Void)

typealias StopwatchTextCompletionHandler = (DFDetectIntentResponse?, NSError?) -> (Void)

enum StopwatchServiceError: Error {
  case unknownError
  case invalidCredentials
  case tokenNotAvailable
}

class StopwatchService {
  var sampleRate: Int = SampleRate
  private var streaming = false

  private var client : DFSessions!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!

  var token : String! {
    didSet {
      NotificationCenter.default.post(name: Notification.Name("TokenReceived"), object: nil, userInfo: nil)

    }
  }

  static let sharedInstance = StopwatchService()

  func authorization() -> String {
    if self.token != nil {
      return "Bearer " + self.token
    } else {
      return "No token is available"
    }
  }

  func streamAudioData(_ audioData: NSData, completion: @escaping StopwatchCompletionHandler) {
    if (!streaming) {
      // if we aren't already streaming, set up a gRPC connection
      client = DFSessions(host:Host)
      writer = GRXBufferedPipe()
      call = client.rpcToStreamingDetectIntent(
        withRequestsWriter: writer,
        eventHandler: { (done, response, error) in
          completion(response, error as NSError?)
      })
      // authenticate using an authorization token (obtained using OAuth)
      call.requestHeaders.setObject(NSString(string:self.authorization()),
                                    forKey:NSString(string:"Authorization"))
      call.start()
      streaming = true

      // send an initial request message to configure the service

      let queryInput = DFQueryInput()
      let inputAudioConfig = DFInputAudioConfig()
      inputAudioConfig.audioEncoding = DFAudioEncoding(rawValue:1)!
      inputAudioConfig.languageCode = "en-US"
      inputAudioConfig.sampleRateHertz = Int32(sampleRate)
      queryInput.audioConfig = inputAudioConfig

      let streamingDetectIntentRequest = DFStreamingDetectIntentRequest()
      streamingDetectIntentRequest.session = "projects/" + ProjectName +
        "/agent/sessions/" + SessionID
      streamingDetectIntentRequest.singleUtterance = true
      streamingDetectIntentRequest.queryParams = getQueryParmasFor()
      streamingDetectIntentRequest.queryInput = queryInput
      streamingDetectIntentRequest.outputAudioConfig = getOutputAudioConfig()
      writer.writeValue(streamingDetectIntentRequest)
    }

    // send a request message containing the audio data
    let streamingDetectIntentRequest = DFStreamingDetectIntentRequest()
    streamingDetectIntentRequest.inputAudio = audioData as Data
    writer.writeValue(streamingDetectIntentRequest)
  }

  func streamText(_ userInput: String, completion: @escaping StopwatchTextCompletionHandler) {
    client = DFSessions(host:Host)
    // send an initial request message to configure the service
    let queryInput = DFQueryInput()
    let inputTextConfig = DFTextInput()
    inputTextConfig.text = userInput
    inputTextConfig.languageCode = "en-US"
    queryInput.text = inputTextConfig
    let detectIntentRequest = DFDetectIntentRequest()
    detectIntentRequest.session = "projects/" + ProjectName +
      "/agent/sessions/" + SessionID
    detectIntentRequest.queryInput = queryInput
    detectIntentRequest.outputAudioConfig = getOutputAudioConfig()
    detectIntentRequest.queryParams = getQueryParmasFor()
    call = client.rpcToDetectIntent(with: detectIntentRequest, handler: { (response, error) in
      completion(response, error as NSError?)
    })
    // authenticate using an authorization token (obtained using OAuth)
    call.requestHeaders.setObject(NSString(string:self.authorization()),
                                  forKey:NSString(string:"Authorization"))
    call.start()
  }

  func getOutputAudioConfig() -> DFOutputAudioConfig? {
    let defaults = UserDefaults.standard
    if let defaultItems = defaults.value(forKey: Constants.selectedMenuItems) as? [Int],
      defaultItems.count > 0 {
      if defaultItems.contains(BetaFeatureMenu.textToSpeech.rawValue) {
        let outputAudioConfig = DFOutputAudioConfig()
        outputAudioConfig.audioEncoding = DFOutputAudioEncoding(rawValue:2)!
        outputAudioConfig.sampleRateHertz = Int32(sampleRate)
        return outputAudioConfig
      }
    }
    return nil
  }

  func getSentimentAnalysisConfig(sentimentSelected: Bool) -> DFSentimentAnalysisRequestConfig {
    let sentimentConfig = DFSentimentAnalysisRequestConfig()
    sentimentConfig.analyzeQueryTextSentiment = sentimentSelected
    return sentimentConfig
  }

  func getQueryParmasFor() -> DFQueryParameters {
    let queryParams = DFQueryParameters()
    let defaults = UserDefaults.standard
    if let defaultItems = defaults.value(forKey: Constants.selectedMenuItems) as? [Int],
      defaultItems.count > 0 {
      let sentimentSelected =
        defaultItems.contains(BetaFeatureMenu.sentimentAnalysis.rawValue)
      queryParams.sentimentAnalysisRequestConfig = getSentimentAnalysisConfig(sentimentSelected: sentimentSelected)

      if defaultItems.contains(BetaFeatureMenu.knowledgeConnector.rawValue) {
        getKnowledgeBasePath { (knowledgeBasePath) in
          queryParams.knowledgeBaseNamesArray = [knowledgeBasePath]
        }
      }
    }else {
      queryParams.sentimentAnalysisRequestConfig = getSentimentAnalysisConfig(sentimentSelected: false)
    }
    return queryParams
  }

  func getKnowledgeBasePath(handler: @escaping (_ KnowledgeBasePath: String) -> Void) {
    let knowledgeBase = DFKnowledgeBases(host: Host)
    let request = DFListKnowledgeBasesRequest()
    request.parent = "projects/\(ProjectName)/agent"
    let call = knowledgeBase.rpcToListKnowledgeBases(with: request, handler: {(knowledgeBaseRes, error) in
      if let error = error {
        print("Error occured while calling knowledge base api \(error.localizedDescription)")
        return
      }
      if let res = knowledgeBaseRes, res.knowledgeBasesArray_Count > 0, let lastKB = res.knowledgeBasesArray.lastObject as? DFKnowledgeBase, let knowledgeBasePath = lastKB.name {
        print("Source response for knowledge base: \(res)")
        print("Found path:\(knowledgeBasePath)")
        handler(knowledgeBasePath)
      }
    })
    // authenticate using an authorization token (obtained using OAuth)
    call.requestHeaders.setObject(NSString(string:self.authorization()),
                                  forKey:NSString(string:"Authorization"))
    call.start()

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
  

