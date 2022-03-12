var exec = require('cordova/exec');

exports.oneTapLogin = function (success, error, options) {
    exec(success, error, 'GoogleSignInPlugin', 'oneTapLogin', [options]);
};

exports.isSignedIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'isSignedIn');
};

exports.signIn = function (success, error, options) {
    exec(success, error, 'GoogleSignInPlugin', 'signIn', [options]);
};

exports.disconnect = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'disconnect');
};

exports.oneTapSignIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'oneTapSignIn');
};

exports.signOut = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signOut');
};