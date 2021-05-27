#import "Permissions.h"

@interface Permissions ()
{
    NSString __block *callbackId;
    NSString __block *callbackIdNotifications;
    CDVPluginResult __block *pluginResult;
    int gpsPermissionType;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation Permissions

- (void)checkGPSPermission: (CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    gpsPermissionType = [command.arguments[0] intValue];
    
    CLLocationManager *locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    switch (gpsPermissionType) {
        case 0:
            if ( locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
                locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }  else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
            
        case 1:
            if (locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }  else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
    }
}

- (void)requestGPSPermission:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    
    gpsPermissionType = [command.arguments[0] intValue];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    switch (gpsPermissionType) {
        case 0:
            [self.locationManager requestWhenInUseAuthorization];
            break;
            
        case 1:
            [self.locationManager requestAlwaysAuthorization];
            break;
    }
}

- (void)checkFitnessPermission:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    
    if (CMMotionActivityManager.authorizationStatus == CMAuthorizationStatusAuthorized) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)checkNotificationsPermission:(CDVInvokedUrlCommand *)command {
    callbackIdNotifications = command.callbackId;
//    self->pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
//    self->pluginResult.keepCallback = @YES;
//    [self.commandDelegate sendPluginResult:self->pluginResult callbackId:self->callbackId];
    
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        BOOL authorized = settings.authorizationStatus == UNAuthorizationStatusAuthorized;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authorized ? @"true" : @"false"];
                self->pluginResult.keepCallback = @YES;
            [self.commandDelegate sendPluginResult:self->pluginResult callbackId:self->callbackIdNotifications];
        });
    }];
}

- (void)requestNotificationsPermission:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:granted ? @"true" : @"false"];
            self->pluginResult.keepCallback = @YES;
            [self.commandDelegate sendPluginResult:self->pluginResult callbackId:self->callbackId];
        });
    }];
}

#pragma mark - Auxiliary functions

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    switch (gpsPermissionType) {
        case 0:
            if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                pluginResult.keepCallback = @YES;
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            } else if (manager.authorizationStatus == kCLAuthorizationStatusDenied){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                pluginResult.keepCallback = @YES;
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
            
        case 1:
            if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                pluginResult.keepCallback = @YES;
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            } else if (manager.authorizationStatus == kCLAuthorizationStatusDenied){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                pluginResult.keepCallback = @YES;
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: @%@", error);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end
