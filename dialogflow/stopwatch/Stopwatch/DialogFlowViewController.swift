//
//  DialogFlowViewController.swift
//  DFSampleUI
//
//  Created by Santhosh Vaddi on 1/20/19.
//  Copyright © 2019 Santhosh Vaddi. All rights reserved.
//

import UIKit
import MaterialComponents
import AVFoundation
import FirebaseFunctions

let selfKey = "Self"
let botKey = "Bot"

class DialogFlowViewController: UIViewController {
    var appBar = MDCAppBar()
    var audioData: NSMutableData!
    var listening: Bool = false
    // Text Field
    var intentTextField: MDCTextField = {
        let usernameTextField = MDCTextField()
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        return usernameTextField
    }()
    var  textFieldBottomConstraint: NSLayoutConstraint!
    let intentTextFieldController: MDCTextInputControllerOutlined
    var tableViewDataSource = [[String: String]]()
    
    //    var audioToTextController = AudioToTextController()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionsCard: MDCCard!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var keybordButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        intentTextFieldController = MDCTextInputControllerOutlined(textInput: intentTextField)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        intentTextFieldController.placeholderText = "Type your intent"
        intentTextField.delegate = self
        
        registerKeyboardNotifications()
        
    }
    
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
    //    audioButton.isEnabled = false
        //Audio Controller initialization
        AudioController.sharedInstance.delegate = self
        StopwatchService.sharedInstance.fetchToken {(error) in
            if let error = error {
                DispatchQueue.main.async { [unowned self] in
                    self.tableViewDataSource.append([botKey: "Error: \(error)\n\nBe sure that you have a valid credentials.json in your app and a working network connection."])
                    self.tableView.reloadData()
                    self.tableView.scrollToBottom()
                }
            } else {
                DispatchQueue.main.async { [unowned self] in
                    self.audioButton.isEnabled = true
                }
            }
        }
        
        setUpNavigationBarAndItems()
        optionsCard.cornerRadius = optionsCard.frame.height/2
        self.view.addSubview(intentTextField)
        intentTextField.isHidden = true
        intentTextField.backgroundColor = .white
        intentTextField.returnKeyType = .send
        
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
        // AppBar Init
        self.addChildViewController(appBar.headerViewController)
        self.appBar.headerViewController.headerView.trackingScrollView = tableView
        appBar.addSubviewsToParent()
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
        
        // Setup Navigation Items
        let menuItemImage = UIImage(named: "MenuItem")
        let templatedMenuItemImage = menuItemImage?.withRenderingMode(.alwaysTemplate)
        let menuItem = UIBarButtonItem(image: templatedMenuItemImage,
                                       style: .plain,
                                       target: nil,
                                       action: nil)
        //        self.navigationItem.leftBarButtonItem = menuItem
        
        let tuneItemImage = UIImage(named: "TuneItem")
        let templatedTuneItemImage = tuneItemImage?.withRenderingMode(.alwaysTemplate)
        let tuneItem = UIBarButtonItem(image: templatedTuneItemImage,
                                       style: .plain,
                                       target: nil,
                                       action: nil)
        //        self.navigationItem.rightBarButtonItem = tuneItem
    }
    
    @IBAction func didTapkeyboard(_ sender: Any) {
        //make intentTF first responder
        intentTextField.isHidden = false
        intentTextField.becomeFirstResponder()  
    }
    
    @IBAction func didTapMicrophone(_ sender: Any) {
        if !listening {
            self.startListening()
        } else {
            self.stopListening()
        }
        
    }
    
}

extension DialogFlowViewController: AudioControllerDelegate {
    func startListening() {
        listening = true
                //button.setTitle("Listening... (Stop)", for: .normal)
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
    
    func stopListening() {
        _ = AudioController.sharedInstance.stop()
        StopwatchService.sharedInstance.stopStreaming()
        //        button.setTitle("Start Listening", for: .normal)
        listening = false
    }
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
                       // strongSelf.tableView.reloadData()
                        strongSelf.tableView.scrollToBottom()
                    } else if let response = response {
                        print(response)
                        if let recognitionResult = response.recognitionResult {
                            if recognitionResult.isFinal {
                                strongSelf.stopListening()
                            }
                        }
                        if !response.queryResult.queryText.isEmpty {
                            strongSelf.tableViewDataSource.append([selfKey: response.queryResult.queryText])
                            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                        }
                        if !response.queryResult.fulfillmentText.isEmpty {
                            strongSelf.tableViewDataSource.append([botKey: response.queryResult.fulfillmentText])
                            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                        }
                        //strongSelf.tableView.reloadData()
                        strongSelf.tableView.scrollToBottom()
                    }
            })
            self.audioData = NSMutableData()
        }
    }
}

extension DialogFlowViewController {
    // MARK: - Keyboard Handling
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name(rawValue: "UIKeyboardWillChangeFrameNotification"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"),
            object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var keyboardFrame =
            (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        textFieldBottomConstraint.constant = -keyboardFrame.height
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        tableView.scrollRectToVisible(keyboardFrame, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textFieldBottomConstraint.constant = 0
        intentTextField.isHidden = true
        var contentInset:UIEdgeInsets = tableView.contentInset
        contentInset.bottom = 0
        tableView.contentInset = contentInset
        
    }
}

extension DialogFlowViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.count > 0 {
            sendTextToDialogFlow(text: text)
            textField.text = ""
        }
        
        return true
    }
    
    func sendTextToDialogFlow(text: String) {
        StopwatchService.sharedInstance.streamText(text, completion: { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            if let error = error, !error.localizedDescription.isEmpty {
                
                strongSelf.tableViewDataSource.append([botKey: error.localizedDescription])
                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                //strongSelf.tableView.reloadData()
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
                //strongSelf.tableView.reloadData()
                strongSelf.tableView.scrollToBottom()
                
            }
        })
    }
}


extension DialogFlowViewController: UITableViewDataSource {
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
