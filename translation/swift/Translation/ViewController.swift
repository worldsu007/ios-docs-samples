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

import UIKit
import MaterialComponents
import googleapis

class ViewController: UIViewController {
  
  var appBar = MDCAppBar()
  // Text Field
  var inputTextField: MDCTextField = {
    let textField = MDCTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()

  var  textFieldBottomConstraint: NSLayoutConstraint!
  let inputTextFieldController: MDCTextInputControllerOutlined
  var tableViewDataSource = [[String: String]]()
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var pickerBackgroundView: UIView!
  @IBOutlet weak var pickerSwapButton: UIBarButtonItem!
  @IBOutlet weak var pickerSourceButton: UIBarButtonItem!
  @IBOutlet weak var pickerTagerButton: UIBarButtonItem!
  
  var sourceLanguageCode = [String]()
  var targetLanguageCode = [String]()
  var glossaryList = [Glossary]()
  var isPickerForLanguage = true
  
  //init with nib name
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    inputTextFieldController = MDCTextInputControllerOutlined(textInput: inputTextField)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    inputTextFieldController.placeholderText = ApplicationConstants.queryTextFieldPlaceHolder
  }
  
  //init with coder
  required init?(coder aDecoder: NSCoder) {
    inputTextFieldController = MDCTextInputControllerOutlined(textInput: inputTextField)
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.tintColor = .black
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    self.title = ApplicationConstants.title
    setUpNavigationBarAndItems()
    registerKeyboardNotifications()
    self.view.addSubview(inputTextField)
    inputTextField.backgroundColor = .white
    inputTextField.returnKeyType = .send
    inputTextFieldController.placeholderText = ApplicationConstants.queryTextFieldPlaceHolder
    inputTextField.delegate = self
    
    // Constraints
    textFieldBottomConstraint = NSLayoutConstraint(item: inputTextField,
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
                                     views: [ "intentTF" : inputTextField]))
    NSLayoutConstraint.activate(constraints)
    let colorScheme = ApplicationScheme.shared.colorScheme
    MDCTextFieldColorThemer.applySemanticColorScheme(colorScheme,
                                                     to: self.inputTextFieldController)
  }

  @IBAction func dismissKeyboardAction(_ sender:Any) {
    inputTextField.resignFirstResponder()
  }
  @IBAction func reverseLanguagesAction(_ sender: Any) {
    print("reverseLanguagesAction")
    let sourceCodeIndex = pickerView.selectedRow(inComponent: 0)
    let targetCodeIndex = pickerView.selectedRow(inComponent: 1)
    pickerView.selectRow(targetCodeIndex, inComponent: 0, animated: true)
    pickerView.selectRow(sourceCodeIndex, inComponent: 1, animated: true)
  }
  
  @IBAction func doneButtonAction(_ sender: Any) {
    pickerBackgroundView.isHidden = true
    view.sendSubviewToBack(pickerBackgroundView)
    if isPickerForLanguage {
      let sourceCodeIndex = pickerView.selectedRow(inComponent: 0)
      let targetCodeIndex = pickerView.selectedRow(inComponent: 1)
      let sourceCode = sourceLanguageCode[sourceCodeIndex]
      let targetCode = targetLanguageCode[targetCodeIndex]
      print("SourceCode = \(sourceCode), TargetCode = \(targetCode)")
      UserDefaults.standard.set(sourceCode, forKey: ApplicationConstants.sourceLanguageCode)
      UserDefaults.standard.set(targetCode, forKey: ApplicationConstants.targetLanguageCode)
    } else {
      let sourceCodeIndex = pickerView.selectedRow(inComponent: 0)
      let sourceCode = glossaryList[sourceCodeIndex].name
      UserDefaults.standard.set(sourceCode, forKey: "SelectedGlossary")
    }
    
  }
  @IBAction func cancelButtonAction(_ sender: Any) {
    pickerBackgroundView.isHidden = true
    view.sendSubviewToBack(pickerBackgroundView)
  }
  func setUpNavigationBarAndItems() {
    //Initialize and add AppBar
    self.addChild(appBar.headerViewController)
    appBar.addSubviewsToParent()
    let barButtonLeadingItem = UIBarButtonItem()
    barButtonLeadingItem.tintColor = ApplicationScheme.shared.colorScheme.primaryColorVariant
    barButtonLeadingItem.image = #imageLiteral(resourceName: "baseline_swap_horiz_black_48pt")
    barButtonLeadingItem.target = self
    barButtonLeadingItem.action = #selector(presentNavigationDrawer)
    appBar.navigationBar.backItem = barButtonLeadingItem
    
    let rightBarButton = UIBarButtonItem()
    rightBarButton.tintColor = ApplicationScheme.shared.colorScheme.primaryColorVariant
    rightBarButton.title = ApplicationConstants.glossaryButton
    rightBarButton.target = self
    rightBarButton.action = #selector(glossaryButtonTapped)
    appBar.navigationBar.rightBarButtonItem = rightBarButton
    MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
  }
  
  @objc func glossaryButtonTapped() {
    let glossaryStatus = UserDefaults.standard.bool(forKey: ApplicationConstants.glossaryStatus)
    let alertVC = UIAlertController(title: ApplicationConstants.glossaryAlertTitle, message: glossaryStatus ? ApplicationConstants.glossaryDisbleAlertMessage : ApplicationConstants.glossaryEnableAlertMessage, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: glossaryStatus ? ApplicationConstants.glossaryAlerOKDisableTitle : ApplicationConstants.glossaryAlertOKEnableTitle, style: .default, handler: { (_) in
      UserDefaults.standard.set(!glossaryStatus, forKey: ApplicationConstants.glossaryStatus)
      if !glossaryStatus {
        self.getListOfGlossary()
      }
    }))
    if glossaryStatus {
      alertVC.addAction(UIAlertAction(title: "Choose glossary" , style: .default, handler: {(_) in
        self.getListOfGlossary()
      }))
    }
    alertVC.addAction(UIAlertAction(title: ApplicationConstants.glossaryAlertCacelTitle, style: .default))
    
    present(alertVC, animated: true)
  }

  @objc func presentNavigationDrawer() {
    // present picker view with languages
    //    self.presentPickerView()
    TextToTranslationService.sharedInstance.getLanguageCodes { (responseObj, error) in
      if let errorText = error {
        self.handleError(error: errorText)
        return
      }
      guard let supportedLanguages = responseObj else {return}
      if supportedLanguages.languagesArray_Count > 0, let languages = supportedLanguages.languagesArray as? [SupportedLanguage] {
        self.sourceLanguageCode = languages.filter({return $0.supportSource }).map({ (supportedLanguage) -> String in
          return supportedLanguage.languageCode
        })
        self.targetLanguageCode = languages.filter({return $0.supportTarget }).map({ (supportedLanguage) -> String in
          return supportedLanguage.languageCode
        })
        self.isPickerForLanguage = true
        self.presentPickerView()
      }
    }
  }
  
  func getListOfGlossary() {
    isPickerForLanguage = false
    TextToTranslationService.sharedInstance.getListOfGlossary { (responseObj, error) in
      if let errorText = error {
        self.handleError(error: errorText)
        return
      }
      guard let response = responseObj else {return}
      print("getListOfGlossary")
      if let glossaryArray = response.glossariesArray as? [Glossary] {
        self.glossaryList = glossaryArray
        self.presentPickerView()
      }
    }
  }
  
  func presentPickerView() {
    pickerBackgroundView.isHidden = false
    view.bringSubviewToFront(pickerBackgroundView)
    pickerView.reloadAllComponents()
    if isPickerForLanguage {
      pickerSourceButton.title = "Source"
      pickerSwapButton.image =  #imageLiteral(resourceName: "baseline_swap_horiz_black_48pt")
      pickerTagerButton.title = "Target"
      guard let sourceCode = UserDefaults.standard.value(forKey: ApplicationConstants.sourceLanguageCode) as? String,
        let targetCode = UserDefaults.standard.value(forKey: ApplicationConstants.targetLanguageCode)  as? String,
        let sourceIndex = sourceLanguageCode.firstIndex(of: sourceCode),
        let targetIndex = targetLanguageCode.firstIndex(of: targetCode)
        else { return }
      
      pickerView.selectRow(sourceIndex, inComponent: 0, animated: true)
      pickerView.selectRow(targetIndex, inComponent: 1, animated: true)
    } else {
      pickerSourceButton.title = "List of Glossaries"
      pickerSwapButton.image = nil
      pickerTagerButton.title = ""
      guard let selectedGlossary = UserDefaults.standard.value(forKey: "SelectedGlossary") as? String,
        let sourceIndex = glossaryList.firstIndex(where: { $0.name == selectedGlossary })
        else { return }
      pickerView.selectRow(sourceIndex, inComponent: 0, animated: true)
    }
  }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return isPickerForLanguage ? 2 : 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return isPickerForLanguage ? max(sourceLanguageCode.count, targetLanguageCode.count) : glossaryList.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if isPickerForLanguage {
      if component == 0 {
        return sourceLanguageCode.count > row ? sourceLanguageCode[row] : ""
      } else {
        return targetLanguageCode.count > row ? targetLanguageCode[row] : ""
      }
    } else {
      
      return glossaryList.count > row ? (glossaryList[row].name.components(separatedBy: "/").last ?? "") : ""
    }
    
  }
}

// MARK: - Keyboard Handling
extension ViewController {
  
  func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame =
      (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    textFieldBottomConstraint.constant = -keyboardFrame.height
    
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    textFieldBottomConstraint.constant = 0
    
  }
}

//MARK: Textfield delegate
extension ViewController: UITextFieldDelegate {
  //Captures the query typed by user
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if let text = textField.text, text.count > 0 {
      textToTranslation(text: text)
      tableViewDataSource.append([ApplicationConstants.selfKey: text])
      tableView.insertRows(at: [IndexPath(row: tableViewDataSource.count - 1, section: 0)], with: .automatic)
    }
    
    textField.text = ""
    return true
  }
  
  func handleError(error: String) {
    let alertVC = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertVC, animated: true)
  }
  
  //start sending text
  func textToTranslation(text: String) {
    TextToTranslationService.sharedInstance.textToTranslate(text: text, completionHandler:
      { (responseObj, error) in
        if let errorText = error {
          self.handleError(error: errorText)
          return
        }
        guard let response = responseObj else {return}
        //Handle success response
        var responseText = ""
        if response.glossaryTranslationsArray_Count > 0, let tResponse = response.glossaryTranslationsArray.firstObject as? Translation {
          responseText = "Glossary: " + tResponse.translatedText + "\n\n"
        }
        if response.translationsArray_Count > 0, let tResponse = response.translationsArray.firstObject as? Translation {
          responseText += ("Translated: " + tResponse.translatedText)
        }
        if !responseText.isEmpty {
          self.tableViewDataSource.append([ApplicationConstants.botKey: responseText])
          self.tableView.insertRows(at: [IndexPath(row: self.tableViewDataSource.count - 1, section: 0)], with: .automatic)
          self.tableView.scrollToBottom()
        }
    })
  }
}

// MARK: Table delegate handling
extension ViewController: UITableViewDataSource {
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


