/**
* Copyright 2019 Google LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
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
const http = require('http');
const https = require('https');

admin.initializeApp(functions.config().firebase);
var db = admin.firestore();

function saveOAuthToken(context, oauthToken) {
var docRef = db.collection('users').doc(context.auth.uid);

var setToken = docRef.set({token: oauthToken});
console.log("Received oauthToken", oauthToken);
}

function generateAccessToken(context, accessToken, tokenType) {
// generate short lived access token
// An object of options to indicate where to post to
var post_options = {
host: 'iamcredentials.googleapis.com',
path: '/v1/projects/-/serviceAccounts/SERVICE-ACCOUNT-NAME@YOUR_PROJECT_ID.iam.gserviceaccount.com:generateAccessToken',
method: 'POST',
headers: {
'Authorization': tokenType + ' ' + accessToken
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
console.log("Calling save oauth token", oauthToken);
saveOAuthToken(context, JSON.parse(oauthToken));
})
});

post_req.on('error', (e) => {
console.log('ERROR: ' + e.message);
});

const body = `{
"delegates": [],
"scope": [
"https://www.googleapis.com/auth/dialogflow"
],
"lifetime": "3599s"
}`;

// post the data
post_req.write(body);
post_req.end();
}


exports.getToken = functions.https.onCall((data, context) => {
// Checking that the user is authenticated.
if (!context.auth) {
// Throwing an HttpsError so that the client gets the error details.
throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' +
'while authenticated.');
}

// Get an access token for the default service account. This service account
// will need to have the IAM Role: ...
// App Engine default service account
var options = {
host: 'metadata.google.internal',
path: '/computeMetadata/v1/instance/service-accounts/default/token',
method: 'GET',
headers: {'Metadata-Flavor': 'Google'}
};

var get_req = http.get(options, (res) => {
var body = '';

res.on('data', (chunk) => {
body += chunk;
});

res.on('end', () => {
const response = JSON.parse(body);
const accessToken = response.access_token;
const tokenType = response.token_type;
console.log("Access token received", accessToken);
generateAccessToken(context, accessToken, tokenType);
})
});

get_req.on('error', (e) => {
console.log('ERROR: ' + e.message);
});
get_req.end();

});