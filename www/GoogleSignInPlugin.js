var exec = require('cordova/exec');

exports.signIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signIn');
};

exports.oneTapSignIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'oneTapSignIn');
};

exports.signOut = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signOut');
};