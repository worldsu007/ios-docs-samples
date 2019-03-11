# Dialogflow Sample

This app demonstrates how to make streaming gRPC connections to the [Dialogflow API](https://cloud.google.com/dialogflow-enterprise/) to recognize commands in recorded audio.

## Prerequisites
- Credentials for calling the Dialogflow API
- An OSX machine or simulator
- [Xcode 9.1][xcode] or later
- [Cocoapods][cocoapods] version 1.0 or later

## Prepare your Google Cloud account
As with all Google Cloud APIs, every call to the Dialogflow API must be associated
  with a project within the [Google Cloud Console][cloud-console] that has the
  API enabled. In brief:
  - Create a project (or use an existing one) in the [Cloud Console][cloud-console]
  - [Enable billing][billing].

## Enable Dialogflow
If you have not already done so, [enable Dialogflow for your project](https://cloud.google.com/dialogflow-enterprise/docs/quickstart). Scripts related to the quickstart are in the SETUP-SERVICE directory.

## Running the app
- In the [Google Cloud Console](https://console.cloud.google.com), use the APIs&Services->Library menu item to find and enable the Dialogflow API.
- Also using the Credentials item in the Google Cloud Console, create a Service Account key. Use the popup to create a key for a "New service account", name it "stopwatch" (this is arbitrary), and give it the role of `Dialogflow API Admin`. Choose a key type of "JSON" and press the "Create" button to download a key file. As a convenience, rename this file to `credentials.json`.
- Clone this repository and `cd` into this directory.
- Copy your `credentials.json` over the skeletal version in this directory. It is used by the scripts in `SETUP_SERVICE` and by the sample application. 
- Be sure that you have gone through the steps in the [Dialogflow quickstart](https://cloud.google.com/dialogflow-enterprise/docs/quickstart) to create and configure your stopwatch agent. Helper scripts for this are in the `SETUP_SERVICE` directory.
- Run ./INSTALL-COCOAPODS to install app dependencies. When it finishes, it will open the Stopwatch workspace in Xcode. Since we are using Cocoapods, be sure to open the workspace and not Stopwatch.xcodeproj.

###  Mark: Firebase authentication steps:

- Create a Firebase project and Set up your app.
- In the Firebase console click on Add Project and call it dialogflowsample-project.
- Click on Create a project.
- To let users sign-in the app we'll use Anonymous Sign in which needs to be enabled.
- In the Firebase Console open the Develop section > Authentication > SIGN IN METHOD tab, You need to enable the Anonymous Sign-in Provider and click SAVE. This will allow users to sign-in the mobile app with Anonymous sign in. This sample app is using Anonymous sign in but the user is free to choose any mode of sign in.
- Create GoogleService-info.plist from Firebase Console open the Settings > Project settings > General > Select iOS from Your apps section then follow the instructions.
- Download GoogleService-info.plist and Add it into root of your xcode project.
- For more info please refer (https://firebase.google.com/docs/ios/setup)


###  Mark: Firebase functions installation steps:

1.  Set up Node.js and the Firebase CLI

 - You'll need a Node.js environment to write functions, and you'll need the Firebase CLI (which also requires Node.js and npm) to deploy functions to the Cloud Functions runtime.
 - For installing Node.js and npm, Node Version Manager is recommended. Once you have Node.js and npm installed, install the Firebase CLI via npm:
 - To install or upgrade the CLI run the following npm command: "npm install -g firebase-tools" from your terminal.
 - To verify that the CLI has been installed correctly, open a console and run: "firebase --version".
 - Authorize the Firebase CLI by running: "firebase login"
 - Make sure you are in the project directory then set up the Firebase CLI to use your Firebase Project: "firebase use --add" Then select your Project ID and follow the instructions.
 
 ## Authentication
 
 - Go to your project root directory, and run the command “firebase init functions”.
 - A functions folder would be created and will have index.js file.
 - Replace index.js file with (https://github.com/santhoshvaddi/nodejs-docs-samples/pull/1/files).
 - Open index.js, go to function generateAccessToken, and replace “SERVICE-ACCOUNT-NAME@YOUR_PROJECT_ID.iam.gserviceaccount.com” with your Service account name and project id. Make sure that your IAM "App Engine Default Service Account" has "Service Account Token Creator" Role.
 - Deploy getOAuthToken method by running command: “firebase deploy —only functions”.
 - For more info please refer (https://firebase.google.com/docs/functions/get-started).

- Replace `your-project-identifier` in `StopwatchService.swift` with the identifier of your Google Cloud project.
- You are now ready to build and run the project. In Xcode you can do this by clicking the 'Play' button in the top left. This will launch the app on the simulator or on the device you've selected. Be sure that the 'Stopwatch' target is selected in the popup near the top left of the Xcode window. 
- Tap the `Mic` button. This uses a custom AudioController class to capture audio in an in-memory instance of NSMutableData. When this data reaches a certain size, it is sent to the StopwatchService class, which streams it to the Dialogflow API. Packets are streamed as instances of the DFStreamingDetectIntentRequest object. The first DFStreamingDetectIntentRequest object sent includes configuration information and subsequent DFStreamingDetectIntentRequest objects contain audio packets. 
- Say a few words and wait for the display to update when your speech is recognized.
- Tap the 'close' button to stop capturing audio, or if audio capture has stopped because your speech was recognized, tap it again to start a new listening session.
- Tap the keyboard button to send the query as text and you can find the 'more' button which will provide to add the additional features to the sample "Sentiment Analysis", "Text to speech", "Knowledge Connector".



[cloud-console]: https://console.cloud.google.com
[git]: https://git-scm.com/
[xcode]: https://developer.apple.com/xcode/
[billing]: https://console.cloud.google.com/billing?project=_
[cocoapods]: https://cocoapods.org/
[Firebase]: https://firebase.google.com/

