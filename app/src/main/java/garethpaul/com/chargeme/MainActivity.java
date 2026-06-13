package garethpaul.com.chargeme;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.Locale;


public class MainActivity extends Activity implements mBatInfoReceiver.TemperatureListener{
    private mBatInfoReceiver myBatInfoReceiver;
    private boolean batteryReceiverRegistered;
    private int level;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        configureActionBar();
        setContentView(R.layout.activity_main);
        setup();
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
        super.onPause();
        unregisterBatteryReceiver();
    }

    @Override
    public void onStop() {
        super.onStop();
        unregisterBatteryReceiver();
    }


    private void setup() {
        registerBatteryReceiver();

        Intent batteryStatus = batteryStatusIntent(this);
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
        batteryTemp.setText(batteryTemperature(this));

        TextView voltageText = (TextView) findViewById(R.id.voltage);
        voltageText.setText(batteryVoltageText(getVoltage()));

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
        int rawLevel = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        if (rawLevel < 0 || scale <= 0) {
            return -1;
        }

        int percent = Math.round((rawLevel * 100.0f) / scale);
        return Math.max(0, Math.min(100, percent));
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

        String technology = batteryStatus.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY);
        if (technology == null || technology.length() == 0) {
            return "Unknown";
        }

        return technology;
    }

    private void registerBatteryReceiver() {
        if (batteryReceiverRegistered) {
            return;
        }

        myBatInfoReceiver = new mBatInfoReceiver(this);
        this.registerReceiver(this.myBatInfoReceiver,
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        batteryReceiverRegistered = true;
    }

    private void unregisterBatteryReceiver() {
        if (!batteryReceiverRegistered) {
            return;
        }

        unregisterReceiver(myBatInfoReceiver);
        myBatInfoReceiver = null;
        batteryReceiverRegistered = false;
    }

    public String getDeviceName() {
        String manufacturer = Build.MANUFACTURER;
        String model = Build.MODEL;
        if (model.startsWith(manufacturer)) {
            return capitalize(model);
        } else {
            return capitalize(manufacturer) + " " + model;
        }
    }


    private String capitalize(String s) {
        if (s == null || s.length() == 0) {
            return "";
        }
        char first = s.charAt(0);
        if (Character.isUpperCase(first)) {
            return s;
        } else {
            return Character.toUpperCase(first) + s.substring(1);
        }
    }

    public static String batteryTemperature(Context context)
    {
        return batteryTemperatureText(batteryStatusIntent(context));
    }

    @Override
    public void onTemperatureChanged(int temperatureTenths) {
        TextView batteryTemp = (TextView) findViewById(R.id.temperature);
        if (batteryTemp != null) {
            batteryTemp.setText(batteryTemperatureText(temperatureTenths));
        }
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
        if (temperatureTenths == Integer.MIN_VALUE) {
            return "Unknown";
        }

        return String.format(Locale.US, "%.1f \u2103", temperatureTenths / 10.0f);
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
        if (millivolts < 0) {
            return "Unknown";
        }

        return String.format(Locale.US, "%.1fV", millivolts / 1000.0f);
    }

    private static String batteryCurrentText(Long currentValue) {
        if (currentValue == null) {
            return "Unknown";
        }

        return String.valueOf(currentValue);
    }

}
