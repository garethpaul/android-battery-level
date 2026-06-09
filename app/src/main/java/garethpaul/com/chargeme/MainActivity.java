package garethpaul.com.chargeme;

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


public class MainActivity extends Activity{
    private mBatInfoReceiver myBatInfoReceiver;
    private boolean batteryReceiverRegistered;
    private int level;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().setDisplayShowTitleEnabled(false);
        getActionBar().setIcon(R.drawable.battery_icon);
        setContentView(R.layout.activity_main);
        setup();
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
        // Health 2 is good

        int health = batteryStatus.getIntExtra(BatteryManager.EXTRA_HEALTH, -1);

        TextView healthText = (TextView) findViewById(R.id.health);
        if (health == 2){
            healthText.setText("Good");
        } else if (health == 7){
            healthText.setText("Cold");
        } else if (health == 4) {
            healthText.setText("Dead");
        } else if (health == 3) {
            healthText.setText("Overheat");
        } else {
            healthText.setText("Unknown");
        }




        int chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
        boolean usbCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_USB;
        boolean acCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_AC;


        TextView plugged = (TextView) findViewById(R.id.plugged);
        if (acCharge == true) {
            plugged.setText("AC Charging");
        } else if (usbCharge == true){
            plugged.setText("USB Charging");
        } else {
            plugged.setText("On Battery");

        }

        TextView current = (TextView) findViewById(R.id.current);
        current.setText(String.valueOf(CurrentReader.getValue()));

        // Battery Level
        TextView levelText = (TextView) findViewById(R.id.level);
        levelText.setText(String.valueOf(level));

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


    }

    private static Intent batteryStatusIntent(Context context) {
        return context.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
    }

    private int batteryLevelPercent(Intent batteryStatus) {
        int rawLevel = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        if (rawLevel < 0 || scale <= 0) {
            return -1;
        }

        return Math.round((rawLevel * 100.0f) / scale);
    }

    private void registerBatteryReceiver() {
        if (batteryReceiverRegistered) {
            return;
        }

        myBatInfoReceiver = new mBatInfoReceiver();
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
        Intent intent = batteryStatusIntent(context);
        if (intent == null) {
            return "Unknown";
        }
        float  temp   = ((float) intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE,0)) / 10;
        return String.valueOf(temp) + " \u2103";
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

}
