/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';
const admin = require('firebase-admin');
const functions = require('firebase-functions');
const express = require('express');
const cookieParser = require('cookie-parser')();
const cors = require('cors')({origin: true});
const app = express();
const querystring = require('querystring');
const https = require('https');
const fs = require('fs');
admin.initializeApp(functions.config().firebase);
var db = admin.firestore();

function saveOAuthToken(context, oauthToken) {
  var docRef = db.collection('users').doc(context.auth.uid);
  var setToken = docRef.set({token: oauthToken});
}

// exports.getOAuthToken = functions.https.onCall((context) => {
// 	var oauthToken = db.collection("users").doc(context.auth.uid);
// 	return oauthToken;
// });

function generateAccessToken(context, accessToken) {
  // generate short lived access token
  // An object of options to indicate where to post to
  var post_options = {
      host: 'iamcredentials.googleapis.com',
      path: '',
      method: 'POST',
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + accessToken
      }
  };
  console.log('Got accessToken', accessToken);
  // Set up the request
  var oauthToken = '';
  var post_req = https.request(post_options, (res) => {
      console.log('Got OAuth Token');
      res.setEncoding('utf8');
      res.on('data', (chunk) => {
          oauthToken += chunk;
      });
      res.on('end', () => {
        // Next step in pipeline
        saveOAuthToken(context, JSON.parse(oauthToken));
      })
  });
  const body = `{
    "delegates": [
      ""
    ],
    "scope": [
      "https://www.googleapis.com/auth/dialogflow"
    ],
    "lifetime": "3599s"
  }`;
  // post the data
  post_req.write(body);
  post_req.end();
}
function authorize(context) {
  var {google} = require("googleapis");
  // Load the service account key JSON file from GCS
  // Define the required scopes.
  var scopes = [
	"https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/dialogflow"
  ];
  // Authenticate a JWT client with the service account.
  var jwtClient = new google.auth.JWT(
    "",
    null,
    "-----BEGIN PRIVATE KEY-----\n==\n-----END PRIVATE KEY-----\n",
	scopes
  );
  // Use the JWT client to generate an access token.
  jwtClient.authorize((error, tokens) => {
    if (error) {
      console.log("Error making request to generate access token:", error);
    } else if (tokens.access_token === null) {
      console.log("Provided service account does not have permission to generate access tokens");
    } else {
		console.log("Access token received", tokens.access_token);
      generateAccessToken(context, tokens.access_token);
    }
  });
}
exports.getToken = functions.https.onCall((data, context) => {
  authorize(context);
});