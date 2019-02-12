//
//  DialogflowViewController.swift
//  DFSampleUI
//
//  Created by Santhosh Vaddi on 1/20/19.
//  Copyright © 2019 Santhosh Vaddi. All rights reserved.
//

import UIKit
import MaterialComponents
import AVFoundation
import googleapis


let selfKey = "Self"
let botKey = "Bot"

class DialogflowViewController: UIViewController {
    var appBar = MDCAppBar()
    var audioData: NSMutableData!
    var listening: Bool = false
    var isFirst: Bool = true
    // Text Field
    var intentTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    var  textFieldBottomConstraint: NSLayoutConstraint!
    let intentTextFieldController: MDCTextInputControllerOutlined
    var tableViewDataSource = [[String: String]]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionsCard: MDCCard!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    
    //init with nib name
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        intentTextFieldController = MDCTextInputControllerOutlined(textInput: intentTextField)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        intentTextFieldController.placeholderText = "Type your intent"
        intentTextField.delegate = self
        
        registerKeyboardNotifications()
        
    }

    //init with coder
    required init?(coder aDecoder: NSCoder) {
        intentTextFieldController = MDCTextInputControllerOutlined(textInput: intentTextField)
        
        super.init(coder: aDecoder)
        intentTextFieldController.placeholderText = "Type your intent"
        intentTextField.delegate = self
        registerKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = .black
        self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
        self.title = "Dialogflow"
        //Audio Controller initialization
        AudioController.sharedInstance.delegate = self
        optionsCard.cornerRadius = optionsCard.frame.height/2
        self.view.addSubview(intentTextField)
        intentTextField.isHidden = true
        intentTextField.backgroundColor = .white
        intentTextField.returnKeyType = .send
        setUpNavigationBarAndItems()
        
        // Constraints
        textFieldBottomConstraint = NSLayoutConstraint(item: intentTextField,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: view,
                                                       attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: 0)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(textFieldBottomConstraint)
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[intentTF]-|",
                                           options: [],
                                           metrics: nil,
                                           views: [ "intentTF" : intentTextField]))
        NSLayoutConstraint.activate(constraints)
        let colorScheme = ApplicationScheme.shared.colorScheme
        MDCTextFieldColorThemer.applySemanticColorScheme(colorScheme,
                                                         to: self.intentTextFieldController)
        
    }
    
    func setUpNavigationBarAndItems() {
         //Initialize and add AppBar
        self.addChildViewController(appBar.headerViewController)
        self.appBar.headerViewController.headerView.trackingScrollView = tableView
        appBar.addSubviewsToParent()
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
    }
    //Action to start text chat bot
    @IBAction func didTapkeyboard(_ sender: Any) {
        //make intentTF first responder
        intentTextField.isHidden = false
        intentTextField.becomeFirstResponder()  
    }
    
    //Action to stat microphone for speech chat
    @IBAction func didTapMicrophone(_ sender: Any) {
        if !listening {
            self.startListening()
        } else {
            self.stopListening()
        }
        
    }
    
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        optionsCard.isHidden = false
        optionsCard.isHidden = true
        DispatchQueue.global().async {
            self.stopListening()
        }
        
    }
    
}

extension DialogflowViewController: AudioControllerDelegate {
    //Microphone start listening
    func startListening() {
        listening = true
        optionsCard.isHidden = true
        cancelButton.isHidden = false
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SampleRate)
        
        StopwatchService.sharedInstance.sampleRate = SampleRate
        _ = AudioController.sharedInstance.start()
    }
    
    //Microphone stops listening
    func stopListening() {
        optionsCard.isHidden = false
        cancelButton.isHidden = true
        _ = AudioController.sharedInstance.stop()
        StopwatchService.sharedInstance.stopStreaming()
        listening = false
    }
    
    //Process sample data
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ =
            Int(0.1 /* seconds/chunk */
                * Double(SampleRate) /* samples/second */
                * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            StopwatchService.sharedInstance.streamAudioData(
                audioData,
                completion: { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    if let error = error, !error.localizedDescription.isEmpty {
                        
                        strongSelf.tableViewDataSource.append([botKey: error.localizedDescription])
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                        strongSelf.tableView.scrollToBottom()
                    } else if let response = response {
                        print(response)
                        print(response.recognitionResult.transcript)
                        if !response.recognitionResult.transcript.isEmpty {
                            if strongSelf.isFirst{
                                strongSelf.tableViewDataSource.append([selfKey: response.recognitionResult.transcript])
                                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                                strongSelf.isFirst = false
                            }else {
                                strongSelf.tableViewDataSource.removeLast()
                                strongSelf.tableViewDataSource.append([selfKey: response.recognitionResult.transcript])
                                strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                            }
                        }
                        if let recognitionResult = response.recognitionResult {
                            if recognitionResult.isFinal {
                                strongSelf.stopListening()
                                strongSelf.isFirst = true
                            }
                        }
                        if !response.queryResult.queryText.isEmpty {
                            strongSelf.tableViewDataSource.removeLast()
                            strongSelf.tableViewDataSource.append([selfKey: response.queryResult.queryText])
                            strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count -  1, section: 0)], with: .automatic)
                        }
                        if !response.queryResult.fulfillmentText.isEmpty {
                            strongSelf.tableViewDataSource.append([botKey: response.queryResult.fulfillmentText])
                            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                        }
                        strongSelf.tableView.scrollToBottom()
                    }
            })
            self.audioData = NSMutableData()
        }
    }
}

// MARK: - Keyboard Handling
extension DialogflowViewController {
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"),
            object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame =
            (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        textFieldBottomConstraint.constant = -keyboardFrame.height
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textFieldBottomConstraint.constant = 0
        intentTextField.isHidden = true
        
    }
}

//MARK: Textfield delegate
extension DialogflowViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.count > 0 {
            sendTextToDialogflow(text: text)
            textField.text = ""
        }
        
        return true
    }
    
    //Start sending text
    func sendTextToDialogflow(text: String) {
        StopwatchService.sharedInstance.streamText(text, completion: { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            if let error = error, !error.localizedDescription.isEmpty {	
                
                strongSelf.tableViewDataSource.append([botKey: error.localizedDescription])
                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                strongSelf.tableView.scrollToBottom()
            } else if let response = response {
                print(response)
                if !response.queryResult.queryText.isEmpty {
                    strongSelf.tableViewDataSource.append([selfKey: response.queryResult.queryText])
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                }
                if !response.queryResult.fulfillmentText.isEmpty {
                    strongSelf.tableViewDataSource.append([botKey: response.queryResult.fulfillmentText])
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                }
                strongSelf.tableView.scrollToBottom()
                
            }
        })
    }
}

// MARK: Table delegate handling
extension DialogflowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewDataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data[selfKey] != nil ? "selfCI" : "intentCI", for: indexPath) as! ChatTableViewCell
        if data[selfKey] != nil {
            cell.selfText.text = data[selfKey]
        } else {
            cell.botResponseText.text = data[botKey]
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
