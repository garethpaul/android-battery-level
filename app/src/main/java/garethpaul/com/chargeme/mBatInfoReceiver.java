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
        return (float)(temp / 10);
    }

    @Override
    public void onReceive(Context arg0, Intent intent) {

        temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE,0);

    }

};