package garethpaul.com.chargeme;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.BatteryManager;

/**
 * Created by gjones on 5/26/15.
 */
public class mBatInfoReceiver extends BroadcastReceiver {

    int temp = 0;

    float get_temp(){
        return temp / 10.0f;
    }

    @Override
    public void onReceive(Context arg0, Intent intent) {
        if (intent == null) {
            return;
        }

        temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, temp);

    }

};
