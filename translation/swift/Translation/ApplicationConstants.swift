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

//MARK: Stopwatch service
struct ApplicationConstants {
  static let Host = "translate.googleapis.com" 
  static let languageCode = "en-US"
  static let projectID = "your-project-identifier"
  static let locationID = "us-central1"
  static let glossaryID = " your-glossary-ID"
}

extension ApplicationConstants {
  static let queryTextFieldPlaceHolder = "Type your input"
  static let menuItemChangedNotification = "menuItemChangedNotification"
  static let mimeType = "text/plain"
}

//MARK: Token generator constants
extension ApplicationConstants {
  static let token = "Token"
  static let accessToken = "accessToken"
  static let expireTime = "expireTime"
  static let tokenReceived = "tokenReceived"
  static let retreivingToken = "RetrievingToken"
  static let getTokenAPI = "getOAuthToken"
  static let tokenType = "Bearer "
  static let noTokenError = "No token is available"
  static let tokenFetchingAlertTitle = "Alert"
  static let tokenFetchingAlertMessage = "Retrieving token ..."
}

//MARK: Bottom drawer
extension ApplicationConstants {
  static let title = "Translation-glossary"
  static let selectedMenuItems = "selected Menu Items"
  static let sentimentAnalysis = "Sentiment"
  static let syntaxAnalysis = "Syntax"
  static let entityAnalysis = "Entity"
  static let category = "Category"
  static let tableViewCellID = "Cell"
  static let menuDrawerTitle = "Tap to enable other analysis for your text"
  static let sourceLanguageCode = "sourceLanguageCode"
  static let targetLanguageCode = "targetLanguageCode"
}

extension ApplicationConstants {
  static let selfKey = "Self"
  static let botKey = "Bot"
  static let moreButtonTitle = "Menu"
  static let sentimentScore = "Sentiment Score:"
  static let sentimentMagnitude = "Sentiment magnitude:"
  static let glossaryButton = "Glossary"
  static let glossaryAlertTitle = "Glossary"
  static let glossaryEnableAlertMessage = "Do you want to enable glossary config?"
  static let glossaryDisbleAlertMessage = "Do you want to disable glossary config?"
  static let glossaryAlertOKEnableTitle = "Yes, enable"
  static let glossaryAlerOKDisableTitle = "Yes, disable"
  static let glossaryAlertCacelTitle = "Cancel"
  static let glossaryStatus = "glossaryStatus"
}
