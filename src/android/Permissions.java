package pt.fidelidade.plugins.permissions;

import android.content.Context;
import android.location.LocationManager;
import android.os.PowerManager;

import androidx.core.app.NotificationManagerCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

public class Permissions extends CordovaPlugin {
    private static String TAG = "Permissions-FIT";

    private static final String ACTION_CHECK_BATTERY_OPTIMIZATION = "checkBatteryOptimization";
    private static final String ACTION_CHECK_GPS_DEVICE_IS_ON = "checkGPSDeviceIsOn";
    private static final String ACTION_CHECK_NOTIFICATIONS = "checkNotificationsPermission";

    private CallbackContext permissionsCallbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        permissionsCallbackContext = callbackContext;

        if (ACTION_CHECK_BATTERY_OPTIMIZATION.equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
                    pluginResult.setKeepCallback(true);
                    checkBatteryOptimization(permissionsCallbackContext);
                }
            });
            return true;
        } else if (ACTION_CHECK_GPS_DEVICE_IS_ON.equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                    pluginResult.setKeepCallback(true);

                    LocationManager locationManager = (LocationManager) cordova.getContext()
                            .getSystemService(Context.LOCATION_SERVICE);
                    if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                        pluginResult = new PluginResult(PluginResult.Status.OK, "true");
                    } else {
                        pluginResult = new PluginResult(PluginResult.Status.OK, "false");
                    }

                    pluginResult.setKeepCallback(true);
                    permissionsCallbackContext.sendPluginResult(pluginResult);
                }
            });
        } else if (ACTION_CHECK_NOTIFICATIONS.equals(action)) {
            Boolean notificationsEnabled = NotificationManagerCompat.from(cordova.getContext())
                    .areNotificationsEnabled();
        }

        return false;
    }

    private void checkBatteryOptimization(CallbackContext callbackContext) {
        PowerManager powerManager = (PowerManager) cordova.getContext().getSystemService(Context.POWER_SERVICE);

        Boolean ignoringBatteryOptimizations = powerManager
                .isIgnoringBatteryOptimizations(cordova.getContext().getPackageName());

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, ignoringBatteryOptimizations);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
    }

}
