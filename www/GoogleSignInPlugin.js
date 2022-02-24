var exec = require('cordova/exec');

exports.isSignedIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'isSignedIn');
};

exports.signIn = function (success, error, options) {
    exec(success, error, 'GoogleSignInPlugin', 'signIn', [options]);
};

exports.disconnect = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'disconnect');
};

exports.signOut = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signOut');
};