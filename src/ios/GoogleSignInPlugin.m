/********* GoogleSignInPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import <GoogleSignIn/GoogleSignIn.h>

@interface GoogleSignInPlugin : CDVPlugin<GIDSignInDelegate, GIDSignInDelegate> {
  // Member variables go here.
}

@property (nonatomic, assign) BOOL isSigningIn;
@property (nonatomic, copy) NSString* callbackId;
@end

@implementation GoogleSignInPlugin

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:CDVPluginHandleOpenURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLWithAppSourceAndAnnotation:) name:CDVPluginHandleOpenURLWithAppSourceAndAnnotationNotification object:nil];
}

//============

- (void)handleOpenURL:(NSNotification*)notification
{
    // no need to handle this handler, we dont have an sourceApplication here, which is required by GIDSignIn handleURL
}

- (void)handleOpenURLWithAppSourceAndAnnotation:(NSNotification*)notification
{
    NSMutableDictionary * options = [notification object];

    NSURL* url = options[@"url"];

    NSString* possibleReversedClientId = [url.absoluteString componentsSeparatedByString:@":"].firstObject;

    if ([possibleReversedClientId isEqualToString:self.getreversedClientId] && self.isSigningIn) {
        self.isSigningIn = NO;
        [[GIDSignIn sharedInstance] handleURL:url];
    }
}

- (void) signIn:(CDVInvokedUrlCommand*)command {
  [[self getGIDSignInObject:command] signIn];
}

- (GIDSignIn*) getGIDSignInObject:(CDVInvokedUrlCommand*)command {
    _callbackId = command.callbackId;
    NSString *reversedClientId = [self getreversedClientId];

    if (reversedClientId == nil) {
        NSDictionary *errorDetails = @{@"status": @"error", @"message": @"Could not find REVERSED_CLIENT_ID url scheme in app .plist"};
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[self toJSONString:errorDetails]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
        return nil;
    }

    NSString *clientId = [self reverseUrlScheme:reversedClientId];

    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.clientID = clientId;

    NSDictionary* options = nil;
    if(command.arguments != nil && [command.arguments count] > 0) {
        options = command.arguments[0];
        
        NSString* scopesString = options[@"scopes"];
        if (scopesString != nil) {
                NSArray* scopes = [scopesString componentsSeparatedByString:@","];
                [signIn setScopes:scopes];
            }
    }
    
    signIn.presentingViewController = self.viewController;
    signIn.delegate = self;

    return signIn;
}

- (NSString*) reverseUrlScheme:(NSString*)scheme {
    NSArray* originalArray = [scheme componentsSeparatedByString:@"."];
    NSArray* reversedArray = [[originalArray reverseObjectEnumerator] allObjects];
    NSString* reversedString = [reversedArray componentsJoinedByString:@"."];
    return reversedString;
}

- (NSString*) getreversedClientId {
    NSArray* URLTypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];

    if (URLTypes != nil) {
        for (NSDictionary* dict in URLTypes) {
            NSString *urlName = dict[@"CFBundleURLName"];
            if ([urlName isEqualToString:@"REVERSED_CLIENT_ID"]) {
                NSArray* URLSchemes = dict[@"CFBundleURLSchemes"];
                if (URLSchemes != nil) {
                    return URLSchemes[0];
                }
            }
        }
    }
    return nil;
}

- (void) signOut:(CDVInvokedUrlCommand*)command {
    [[GIDSignIn sharedInstance] signOut];
    NSDictionary *details = @{@"status": @"success", @"message": @"Logged out"};
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self toJSONString:details]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) disconnect:(CDVInvokedUrlCommand*)command {
    [[GIDSignIn sharedInstance] disconnect];
    NSDictionary *details = @{@"status": @"success", @"message": @"Disconnected"};
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self toJSONString:details]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isSignedIn:(CDVInvokedUrlCommand*)command {
    bool isSignedIn = [[GIDSignIn sharedInstance] currentUser] != nil;
    NSDictionary *details = @{@"status": @"success", @"message": (isSignedIn) ? @"true" : @"false"};
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self toJSONString:details]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        NSDictionary *errorDetails = @{@"status": @"error", @"message": error.localizedDescription};
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[self toJSONString:errorDetails]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
    } else {
        NSString *email = user.profile.email;
        NSString *userId = user.userID;
        NSURL *imageUrl = [user.profile imageURLWithDimension:120]; // TODO pass in img size as param, and try to sync with Android
        NSDictionary *result = @{
                       @"email"            : email,
                       @"id"               : userId,
                       @"id_token"         : user.authentication.idToken,
                       @"display_name"     : user.profile.name       ? : [NSNull null],
                       @"given_name"       : user.profile.givenName  ? : [NSNull null],
                       @"family_name"      : user.profile.familyName ? : [NSNull null],
                       @"photo_url"        : imageUrl ? imageUrl.absoluteString : [NSNull null],
                       };

        NSDictionary *user = @{@"user": result};
        
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [self toJSONString:user]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
    }
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    self.isSigningIn = YES;
    [self.viewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)toJSONString:(NSDictionary*)dictionaryOrArray {
    NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryOrArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
         if (! jsonData) {
            NSLog(@"%s: error: %@", __func__, error.localizedDescription);
            return @"{}";
         } else {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         }
}

@end
