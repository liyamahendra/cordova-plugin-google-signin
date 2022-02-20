var exec = require('cordova/exec');

exports.signIn = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signIn');
};

exports.signOut = function (success, error) {
    exec(success, error, 'GoogleSignInPlugin', 'signOut');
};