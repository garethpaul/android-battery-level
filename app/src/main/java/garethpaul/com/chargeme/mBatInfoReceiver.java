package garethpaul.com.chargeme;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Created by gjones on 5/26/15.
 */
public class mBatInfoReceiver extends BroadcastReceiver {

    public interface BatteryStatusListener {
        void onBatteryStatusChanged(Intent batteryStatus);
    }

    private final BatteryStatusListener batteryStatusListener;

    public mBatInfoReceiver(BatteryStatusListener batteryStatusListener) {
        this.batteryStatusListener = batteryStatusListener;
    }

    @Override
    public void onReceive(Context arg0, Intent intent) {
        if (intent == null) {
            return;
        }

        if (batteryStatusListener != null) {
            batteryStatusListener.onBatteryStatusChanged(intent);
        }

    }

};
