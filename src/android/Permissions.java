package pt.fidelidade.plugins.permissions;

import android.content.Context;
import android.os.BatteryManager;
import android.os.PowerManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

public class Permissions extends CordovaPlugin {
    private static String TAG = "Permissions-FIT";

    private static final String ACTION_CHECK_BATTERY_OPTIMIZATION = "checkBatteryOptimization";

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
        }
        return false;
    }

    private void checkBatteryOptimization(CallbackContext callbackContext) {
        PowerManager powerManager = (PowerManager) cordova.getContext().getSystemService(Context.POWER_SERVICE);

        Boolean ignoringBatteryOptimizations = powerManager
                .isIgnoringBatteryOptimizations(cordova.getContext().getPackageName());

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, ignoringBatteryOptimizations);
        callbackContext.sendPluginResult(pluginResult);
    }
}
