#import "Permissions.h"

typedef enum : NSUInteger {
    GENERAL,
    BACKGROUND,
} GpsPermissionType;

@interface Permissions ()
{
    NSString __block *callbackId;
    CDVPluginResult __block *pluginResult;
    GpsPermissionType gpsPermissionType;
}
@end

@implementation Permissions

- (void)checkGPSPermission: (CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    gpsPermissionType = (GpsPermissionType)command.arguments[1];
    
    CLLocationManager *locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    switch (gpsPermissionType) {
        case GENERAL:
            if ([locationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                pluginResult = [CDVPluginResult new];
                pluginResult.keepCallback = @YES;
                [locationManager requestWhenInUseAuthorization];
            } else {
                if (locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
                }  else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
                }
            }
            break;
            
        case BACKGROUND:
            if ([locationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                pluginResult = [CDVPluginResult new];
                pluginResult.keepCallback = @YES;
                [locationManager requestAlwaysAuthorization];
            } else {
                if (locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
                }  else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
                }
            }
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
    callbackId = command.callbackId;
    
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus != UNAuthorizationStatusNotDetermined) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL authorized = settings.authorizationStatus == UNAuthorizationStatusAuthorized;
                self->pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authorized ? @"true" : @"false"];
                self->pluginResult.keepCallback = @YES;
                [self.commandDelegate sendPluginResult:self->pluginResult callbackId:self->callbackId];
            });
        } else {
            [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:granted ? @"true" : @"false"];
                    self->pluginResult.keepCallback = @YES;
                    [self.commandDelegate sendPluginResult:self->pluginResult callbackId:self->callbackId];
                });
            }];
        }
    }];
}

#pragma mark - Auxiliary functions

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    switch (gpsPermissionType) {
        case GENERAL:
            if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
            
        case BACKGROUND:
            if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
                [self.commandDelegate sendPluginResult: pluginResult callbackId:callbackId];
            }
            break;
    }
}

@end
