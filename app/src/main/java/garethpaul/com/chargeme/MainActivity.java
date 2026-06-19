package garethpaul.com.chargeme;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;


public class MainActivity extends Activity implements mBatInfoReceiver.BatteryStatusListener{
    private mBatInfoReceiver myBatInfoReceiver;
    private boolean batteryReceiverRegistered;
    private int level;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        configureActionBar();
        setContentView(R.layout.activity_main);
    }

    private void configureActionBar() {
        ActionBar actionBar = getActionBar();
        if (actionBar == null) {
            return;
        }

        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setIcon(R.drawable.battery_icon);
    }

    @Override
    protected void onResume() {
        super.onResume();
        setup();
    }

    @Override
    public void onPause() {
        unregisterBatteryReceiver();
        super.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
        unregisterBatteryReceiver();
    }


    private void setup() {
        registerBatteryReceiver();
    }

    private void renderBatteryStatus(Intent batteryStatus) {
        if (batteryStatus == null) {
            return;
        }

        level = batteryLevelPercent(batteryStatus);

        TextView stateText = (TextView) findViewById(R.id.state);
        stateText.setText(batteryStatusText(
                batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1)));

        int health = batteryStatus.getIntExtra(BatteryManager.EXTRA_HEALTH, -1);

        TextView healthText = (TextView) findViewById(R.id.health);
        healthText.setText(batteryHealthText(health));




        int chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);

        TextView plugged = (TextView) findViewById(R.id.plugged);
        plugged.setText(batteryPluggedText(chargePlug));

        TextView current = (TextView) findViewById(R.id.current);
        current.setText(batteryCurrentText(CurrentReader.getValue()));

        // Battery Level
        TextView levelText = (TextView) findViewById(R.id.level);
        levelText.setText(batteryLevelText(level));

        ImageView batteryImage = (ImageView) findViewById(R.id.battery);

        if (level < 0) {
            batteryImage.setImageResource(R.drawable.battery_icon);
        } else if (level < 30){
            batteryImage.setImageResource(R.drawable.battery_red);
        } else if (level < 65) {
            batteryImage.setImageResource(R.drawable.battery_orange);
        } else {
            batteryImage.setImageResource(R.drawable.battery_green);
        }

        TextView batteryTemp = (TextView) findViewById(R.id.temperature);
        batteryTemp.setText(batteryTemperatureText(batteryStatus));

        TextView voltageText = (TextView) findViewById(R.id.voltage);
        voltageText.setText(batteryVoltageText(
                batteryStatus.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)));

        TextView modelText = (TextView) findViewById(R.id.model);
        modelText.setText(getDeviceName());

        TextView technologyText = (TextView) findViewById(R.id.tech);
        technologyText.setText(batteryTechnologyText(batteryStatus));

    }

    private static Intent batteryStatusIntent(Context context) {
        if (context == null) {
            return null;
        }

        return context.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
    }

    private int batteryLevelPercent(Intent batteryStatus) {
        return BatteryTelemetry.levelPercent(
                batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1),
                batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1));
    }

    private static String batteryLevelText(int levelPercent) {
        if (levelPercent < 0) {
            return "Unknown";
        }

        return String.valueOf(levelPercent);
    }

    private static String batteryStatusText(int status) {
        switch (status) {
            case BatteryManager.BATTERY_STATUS_CHARGING:
                return "Charging";
            case BatteryManager.BATTERY_STATUS_DISCHARGING:
                return "Discharging";
            case BatteryManager.BATTERY_STATUS_FULL:
                return "Full";
            case BatteryManager.BATTERY_STATUS_NOT_CHARGING:
                return "Not Charging";
            default:
                return "Unknown";
        }
    }

    private static String batteryHealthText(int health) {
        switch (health) {
            case BatteryManager.BATTERY_HEALTH_COLD:
                return "Cold";
            case BatteryManager.BATTERY_HEALTH_DEAD:
                return "Dead";
            case BatteryManager.BATTERY_HEALTH_GOOD:
                return "Good";
            case BatteryManager.BATTERY_HEALTH_OVERHEAT:
                return "Overheat";
            default:
                return "Unknown";
        }
    }

    private static String batteryPluggedText(int chargePlug) {
        switch (chargePlug) {
            case BatteryManager.BATTERY_PLUGGED_AC:
                return "AC Charging";
            case BatteryManager.BATTERY_PLUGGED_USB:
                return "USB Charging";
            case BatteryManager.BATTERY_PLUGGED_WIRELESS:
                return "Wireless Charging";
            case 0:
                return "On Battery";
            default:
                return "Unknown";
        }
    }

    private static String batteryTechnologyText(Intent batteryStatus) {
        if (batteryStatus == null) {
            return "Unknown";
        }

        return BatteryTelemetry.normalizedLabel(
                batteryStatus.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY));
    }

    private void registerBatteryReceiver() {
        if (batteryReceiverRegistered) {
            return;
        }

        myBatInfoReceiver = new mBatInfoReceiver(this);
        Intent batteryStatus = this.registerReceiver(this.myBatInfoReceiver,
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        batteryReceiverRegistered = true;
        renderBatteryStatus(batteryStatus);
    }

    private void unregisterBatteryReceiver() {
        if (!batteryReceiverRegistered) {
            return;
        }

        mBatInfoReceiver receiver = myBatInfoReceiver;
        myBatInfoReceiver = null;
        batteryReceiverRegistered = false;
        try {
            unregisterReceiver(receiver);
        } catch (IllegalArgumentException unregisterFailure) {
            Log.e("ChargeMe", "battery receiver unregister failed");
        }
    }

    public String getDeviceName() {
        return BatteryTelemetry.deviceName(Build.MANUFACTURER, Build.MODEL);
    }

    public static String batteryTemperature(Context context)
    {
        return batteryTemperatureText(batteryStatusIntent(context));
    }

    @Override
    public void onBatteryStatusChanged(Intent batteryStatus) {
        renderBatteryStatus(batteryStatus);
    }

    private static String batteryTemperatureText(Intent intent) {
        if (intent == null || !intent.hasExtra(BatteryManager.EXTRA_TEMPERATURE)) {
            return "Unknown";
        }

        int temperatureTenths = intent.getIntExtra(
                BatteryManager.EXTRA_TEMPERATURE,
                Integer.MIN_VALUE);
        if (temperatureTenths == Integer.MIN_VALUE) {
            return "Unknown";
        }

        return batteryTemperatureText(temperatureTenths);
    }

    private static String batteryTemperatureText(int temperatureTenths) {
        return BatteryTelemetry.temperatureText(temperatureTenths);
    }

    public int getVoltage()
    {
        Intent b = batteryStatusIntent(this);
        if (b == null) {
            return -1;
        }
        return b.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1);
    }

    private static String batteryVoltageText(int millivolts) {
        return BatteryTelemetry.voltageText(millivolts);
    }

    private static String batteryCurrentText(Long currentValue) {
        return BatteryTelemetry.currentText(currentValue);
    }

}
