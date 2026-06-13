package garethpaul.com.chargeme;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.BatteryManager;

/**
 * Created by gjones on 5/26/15.
 */
public class mBatInfoReceiver extends BroadcastReceiver {

    public interface BatteryStatusListener {
        void onBatteryStatusChanged(Intent batteryStatus);
    }

    int temp = 0;
    private final BatteryStatusListener batteryStatusListener;

    public mBatInfoReceiver(BatteryStatusListener batteryStatusListener) {
        this.batteryStatusListener = batteryStatusListener;
    }

    float get_temp(){
        return temp / 10.0f;
    }

    @Override
    public void onReceive(Context arg0, Intent intent) {
        if (intent == null) {
            return;
        }

        if (batteryStatusListener != null) {
            batteryStatusListener.onBatteryStatusChanged(intent);
        }

        if (!intent.hasExtra(BatteryManager.EXTRA_TEMPERATURE)) {
            return;
        }

        int receivedTemperature = intent.getIntExtra(
                BatteryManager.EXTRA_TEMPERATURE,
                Integer.MIN_VALUE);
        if (receivedTemperature != Integer.MIN_VALUE) {
            temp = receivedTemperature;
        }

    }

};
