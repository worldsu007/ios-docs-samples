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
import AVFoundation
import googleapis
import MaterialComponents

let SAMPLE_RATE = 16000

class SpeechViewController : UIViewController, AudioControllerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var optionsCard: MDCCard!
  @IBOutlet weak var audioButton: UIButton!

  var audioData = NSMutableData()
  var appBar = MDCAppBar()
  var listening: Bool = false
  var tableViewDataSource = [[String: String]]()
  var isFirst = true
  var avPlayer: AVAudioPlayer?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.tintColor = .black
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    self.title = ApplicationConstants.SpeechScreenTitle
    setUpNavigationBarAndItems()
    optionsCard.cornerRadius = optionsCard.frame.height/2
    AudioController.sharedInstance.delegate = self
  }

  func setUpNavigationBarAndItems() {
    //Initialize and add AppBar
    self.addChild(appBar.headerViewController)
    self.appBar.headerViewController.headerView.trackingScrollView = tableView
    appBar.addSubviewsToParent()

    MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
  }

  @IBAction func recordAudio(_ sender: UIButton) {
    if listening {//Stop the audio
      _ = AudioController.sharedInstance.stop()
      SpeechRecognitionService.sharedInstance.stopStreaming()
      listening = false
      audioButton.setImage(#imageLiteral(resourceName: "Mic"), for: .normal)
    } else {//Record the audio
      audioData = NSMutableData()
      _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
      SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
      _ = AudioController.sharedInstance.start()
      listening = true
      audioButton.setImage(#imageLiteral(resourceName: "CancelButton"), for: .normal)
    }
  }

  func processSampleData(_ data: Data) -> Void {
    audioData.append(data)
    // We recommend sending samples in 100ms chunks
    let chunkSize : Int /* bytes/chunk */ =
      Int(0.1 /* seconds/chunk */
        * Double(SAMPLE_RATE) /* samples/second */
        * 2 /* bytes/sample */);
    if (audioData.length > chunkSize) {
      SpeechRecognitionService.sharedInstance.streamAudioData(audioData,completion:
        { [weak self] (response, error) in
          guard let strongSelf = self else {
            return
          }
          if let error = error {
            strongSelf.handleError(error: error)
          } else if let response = response, let resultArray = response.resultsArray as? [StreamingRecognitionResult] {
            print(response)
            for result in resultArray {
              if result.isFinal {
                strongSelf.recordAudio(strongSelf.audioButton)
                strongSelf.isFirst = true
                let text = (result.alternativesArray?.firstObject as? SpeechRecognitionAlternative)?.transcript ?? ""
                strongSelf.tableViewDataSource.removeLast()
                strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: text])
                strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                //Received transcript, sending it to Translation API
                //MARK:- Call Translation API
                TranslationServices.sharedInstance.translateText(text: text, completionHandler: {(response, errorString) in
                  if let error = errorString {
                    strongSelf.showErrorAlert(message: error)
                  } else if let response = response {
                    guard let translatedObj = response.translationsArray.firstObject as? Translation, let translatedText = translatedObj.translatedText else {return}
                    strongSelf.tableViewDataSource.append([ApplicationConstants.botKey: translatedText])
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                    //Received translated text, sending it to Speech to text API
                    //MARK:- Call STT API
                    TextToSpeechRecognitionService.sharedInstance.textToSpeech(text: translatedText, completionHandler: {(audioData, errorString) in
                      if let error = errorString {
                        strongSelf.showErrorAlert(message: error)
                      } else if let audioData = audioData {
                        self?.audioPlayerFor(audioData: audioData)
                        print("playing audio")
                      }
                    })
                  }
                })
              } else {
                if let firstAlternativeResult = result.alternativesArray?.firstObject as? SpeechRecognitionAlternative, !firstAlternativeResult.transcript.isEmpty {
                  if strongSelf.isFirst {
                    strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: firstAlternativeResult.transcript])
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                    strongSelf.isFirst = false
                  } else {
                    strongSelf.tableViewDataSource.removeLast()
                    strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: firstAlternativeResult.transcript])
                    strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                  }
                }
              }
            }
            strongSelf.tableView.scrollToBottom()
          }
      })
      self.audioData = NSMutableData()
    }
  }
}

//MARK: helper functions
extension SpeechViewController {

  func showErrorAlert(message: String){
    let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertVC, animated: true)
  }
  
  func handleError(error: Error) {
    showErrorAlert(message: error.localizedDescription)
  }

  func audioPlayerFor(audioData: Data) {
    DispatchQueue.main.async {
      do {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        self.avPlayer = try AVAudioPlayer(data: audioData)
        if let _ = self.avPlayer {
          self.avPlayer?.prepareToPlay()
          self.avPlayer?.play()
        }

      } catch let error {
        print("Error occurred while playing audio: \(error.localizedDescription)")
      }
    }
  }
}

// MARK: Table delegate handling
extension SpeechViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableViewDataSource.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = tableViewDataSource[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: data[ApplicationConstants.selfKey] != nil ? "selfCI" : "intentCI", for: indexPath) as! ChatTableViewCell
    if data[ApplicationConstants.selfKey] != nil {
      cell.selfText.text = data[ApplicationConstants.selfKey]
    } else {
      cell.botResponseText.text = data[ApplicationConstants.botKey]
    }
    return cell
  }
}

extension UITableView {
  func  scrollToBottom(animated: Bool = true) {
    let sections = self.numberOfSections
    let rows = self.numberOfRows(inSection: sections - 1)
    if (rows > 0) {
      self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
    }
  }
}
