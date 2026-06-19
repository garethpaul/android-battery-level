package garethpaul.com.chargeme;

import android.app.Application;
import android.content.Intent;
import android.test.ApplicationTestCase;

/**
 * <a href="http://d.android.com/tools/testing/testing_android.html">Testing Fundamentals</a>
 */
public class ApplicationTest extends ApplicationTestCase<Application> {
    public ApplicationTest() {
        super(Application.class);
    }

    public void testBatteryReceiverForwardsOnlyNonNullIntents() {
        final int[] callbacks = {0};
        mBatInfoReceiver receiver = new mBatInfoReceiver(
                new mBatInfoReceiver.BatteryStatusListener() {
                    @Override
                    public void onBatteryStatusChanged(Intent batteryStatus) {
                        callbacks[0]++;
                    }
                });

        receiver.onReceive(getContext(), null);
        receiver.onReceive(getContext(), new Intent(Intent.ACTION_BATTERY_CHANGED));

        assertEquals(1, callbacks[0]);
    }

    public void testTelemetryRejectsUnsafeVendorValues() {
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("model\nspoof"));
        assertEquals("Unknown", BatteryTelemetry.deviceName("\u202EelgooG", "Pixel"));
        assertEquals("Unknown", BatteryTelemetry.voltageText(100001));
        assertEquals("Unknown", BatteryTelemetry.currentText(Long.valueOf(Long.MAX_VALUE)));
    }
}
