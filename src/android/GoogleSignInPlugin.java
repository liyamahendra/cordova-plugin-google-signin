package com.devapps;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;

/**
 * This class echoes a string called from JavaScript.
 */
public class GoogleSignInPlugin extends CordovaPlugin {

    private static final int RC_SIGN_IN = 101;
    private GoogleSignInAccount account;
    private Context mContext;
    private Activity mCurrentActivity;
    private CallbackContext mCallbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        mCurrentActivity = this.cordova.getActivity();
        mContext = this.cordova.getActivity().getApplicationContext();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("signIn")) {
            this.signIn(callbackContext);
            return true;
        } else if (action.equals("signOut")) {
            this.signOut(callbackContext);
            return true;
        }
        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_SIGN_IN) {
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                account = task.getResult(ApiException.class);
                JSONObject userInfo = new JSONObject();
                userInfo.put("id", account.getId());
                userInfo.put("email", account.getEmail());
                userInfo.put("display_name", account.getDisplayName());
                userInfo.put("family_name", account.getFamilyName());
                userInfo.put("given_name", account.getGivenName());
                userInfo.put("photo_url", account.getPhotoUrl());
                String dataToSend = "{\"status\" : \"success\", \"user\" : " + userInfo.toString() + "}";
                mCallbackContext.success(dataToSend);
            } catch (Exception e) {
                System.out.println("Google sign in failed: " + e);
                mCallbackContext.error("{\"status\" : \"error\", \"message\" : " + e.getMessage() + "}");
            }
        }
    }

    private void signIn(CallbackContext callbackContext) {
        mCallbackContext = callbackContext;
        signIn();
    }

    private void signOut(CallbackContext callbackContext) {
        mCallbackContext = callbackContext;
        signOut();
    }

    private void signIn() {
        if (account == null) {
            cordova.setActivityResultCallback(this);
            
            GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                    .requestEmail()
                    .build();

            GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(mContext, gso);
            Intent signInIntent = mGoogleSignInClient.getSignInIntent();
            mCurrentActivity.startActivityForResult(signInIntent, RC_SIGN_IN);
        }
    }

    private void signOut() {
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                .build();

        GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(mContext, gso);
        mGoogleSignInClient.signOut().addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                account = null;
                mCallbackContext.success("{\"status\" : \"success\", \"message\":\"Logged out\"}");
            }
        });
        mGoogleSignInClient.signOut().addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                mCallbackContext.error("{\"status\" : \"error\", \"message\" : \"" + e.getMessage() + "\"}");
            }
        });
    }
}
