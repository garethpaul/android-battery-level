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


public class MainActivity extends Activity{
    private mBatInfoReceiver myBatInfoReceiver;
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
        setup();
    }

    @Override
    public void onStop() {
        super.onStop();
        setup();
    }


    private void setup() {

        myBatInfoReceiver = new mBatInfoReceiver();

        this.registerReceiver(this.myBatInfoReceiver,
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED));


        //
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = this.registerReceiver(null, ifilter);

        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);

        level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
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

        if (level > 0 && level < 30){
            batteryImage.setImageResource(R.drawable.battery_red);
        } else if (level > 31 && level < 65) {
            batteryImage.setImageResource(R.drawable.battery_orange);
        } else {
            batteryImage.setImageResource(R.drawable.battery_green);
        }

        TextView batteryTemp = (TextView) findViewById(R.id.temperature);
        batteryTemp.setText(batteryTemperature(this));

        TextView voltageText = (TextView) findViewById(R.id.voltage);
        voltageText.setText(String.valueOf(getVoltage()) + "V");

        TextView modelText = (TextView) findViewById(R.id.model);
        modelText.setText(getDeviceName());


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
        Intent intent = context.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        float  temp   = ((float) intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE,0)) / 10;
        return String.valueOf(temp) + " \u2103";
    }

    public int getVoltage()
    {
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent b = this.registerReceiver(null, ifilter);
        return b.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1);
    }

}
