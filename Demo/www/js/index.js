/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {

    document.getElementById("btnStartCheck").addEventListener("click", oneTapLogin);
    document.getElementById("btnIsSignedIn").addEventListener("click", isSignedIn);
    document.getElementById("btnSignIn").addEventListener("click", signIn);
    document.getElementById("btnDisconnect").addEventListener("click", disconnect);
    document.getElementById("btnSignOut").addEventListener("click", signOut);

    document.getElementById("btnSignIn").style.display = "block";
    document.getElementById("btnDisconnect").style.display = "none";
    document.getElementById("btnSignOut").style.display = "none";
}

function oneTapLogin() {
    console.log("*** oneTapLogin called from JavaScript ***");
    cordova.plugins.GoogleSignInPlugin.oneTapLogin(function(successResponse) {
            var response = JSON.parse(successResponse);
            var user = response.user;

            var data = "";
            data += "ID: " + user.id + "<br />";
            data += "Email: " + user.email + "<br />";
            data += "Display Name: " + user.display_name + "<br />";
            data += "Photo URL: " + user.photo_url + "<br />";
            data += "ID Token: " + user.id_token + "<br />";

            document.getElementById('details').innerHTML = data;

            document.getElementById("btnDisconnect").style.display = "block";
            document.getElementById("btnSignOut").style.display = "block";

        }, function(errorResponse) {
            document.getElementById('details').innerHTML = errorResponse;
        });
}

function isSignedIn() {
    cordova.plugins.GoogleSignInPlugin.isSignedIn(function(successResponse) {
        alert(successResponse);
    }, function(errorResponse) {
        alert(errorResponse);
    });
}

function signIn() {
    cordova.plugins.GoogleSignInPlugin.signIn(function(successResponse) {
        var response = JSON.parse(successResponse);
        var user = response.user;

        var data = "";
        data += "ID: " + user.id + "<br />";
        data += "Email: " + user.email + "<br />";
        data += "Display Name: " + user.display_name + "<br />";
        data += "Photo URL: " + user.photo_url + "<br />";
        data += "ID Token: " + user.id_token + "<br />";

        document.getElementById('details').innerHTML = data;

        document.getElementById("btnDisconnect").style.display = "block";
        document.getElementById("btnSignOut").style.display = "block";
    }, function(errorResponse) {
        document.getElementById('details').innerHTML = errorResponse;
    }, {});
}

function signOut() {
    cordova.plugins.GoogleSignInPlugin.signOut(function(successResponse) {
        document.getElementById('details').innerHTML = successResponse;

        document.getElementById("btnSignIn").style.display = "block";
        document.getElementById("btnDisconnect").style.display = "none";
        document.getElementById("btnSignOut").style.display = "none";
    }, function(errorResponse) {
        document.getElementById('details').innerHTML = errorResponse;
    });
}

function disconnect() {
    cordova.plugins.GoogleSignInPlugin.disconnect(function(successResponse) {
        document.getElementById('details').innerHTML = successResponse;

        document.getElementById("btnSignIn").style.display = "block";
    }, function(errorResponse) {
        document.getElementById('details').innerHTML = errorResponse;
    });
}
