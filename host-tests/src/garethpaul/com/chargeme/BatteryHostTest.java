package garethpaul.com.chargeme;

import android.content.Intent;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

public final class BatteryHostTest {
    private static int assertions;

    public static void main(String[] args) {
        testTelemetryBoundaries();
        testVendorLabelSanitization();
        testCurrentSourceUnitsAndFallbacks();
        testOneLineParsing();
        testReceiverDeliveryBoundaries();
        System.out.println("BatteryHostTest: " + assertions + " assertions passed");
    }

    private static void testTelemetryBoundaries() {
        assertEquals(-1, BatteryTelemetry.levelPercent(-1, 100));
        assertEquals(-1, BatteryTelemetry.levelPercent(50, 0));
        assertEquals(50, BatteryTelemetry.levelPercent(1, 2));
        assertEquals(100, BatteryTelemetry.levelPercent(Integer.MAX_VALUE, 1));

        assertEquals("25.0 ℃", BatteryTelemetry.temperatureText(250));
        assertEquals("Unknown", BatteryTelemetry.temperatureText(Integer.MIN_VALUE));
        assertEquals("Unknown", BatteryTelemetry.temperatureText(2001));
        assertEquals("Unknown", BatteryTelemetry.temperatureText(-1001));

        assertEquals("4.2V", BatteryTelemetry.voltageText(4200));
        assertEquals("Unknown", BatteryTelemetry.voltageText(0));
        assertEquals("Unknown", BatteryTelemetry.voltageText(100001));

        assertEquals("-125", BatteryTelemetry.currentText(Long.valueOf(-125)));
        assertEquals("Unknown", BatteryTelemetry.currentText(null));
        assertEquals("Unknown", BatteryTelemetry.currentText(Long.valueOf(1000001L)));
        assertEquals("Unknown", BatteryTelemetry.currentText(Long.valueOf(-1000001L)));
    }

    private static void testVendorLabelSanitization() {
        assertEquals("Li-ion", BatteryTelemetry.normalizedLabel("  Li-ion  "));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\u202Etxt"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("model\nspoof"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\u00A0\u2003"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\u034F"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\u0301"));
        assertEquals("Cafe\u0301", BatteryTelemetry.normalizedLabel("Cafe\u0301"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\u180B"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\uFE0F"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\uDB40\uDD00"));
        assertEquals("Unknown", BatteryTelemetry.normalizedLabel("\uDB40\uDC01"));
        assertEquals("Li-ion\uFE0F", BatteryTelemetry.normalizedLabel("Li-ion\uFE0F"));
        assertEquals("Li-ion\uDB40\uDD00", BatteryTelemetry.normalizedLabel("Li-ion\uDB40\uDD00"));
        assertEquals("Google Pixel", BatteryTelemetry.deviceName("google", "Pixel"));
        assertEquals("Google Pixel", BatteryTelemetry.deviceName("google", "pixel"));
        assertEquals("Google Pixel", BatteryTelemetry.deviceName("Google", "google Pixel"));
        assertEquals("Unknown", BatteryTelemetry.deviceName("\u202EelgooG", "Pixel"));
        assertEquals("Unknown", BatteryTelemetry.deviceName("\u00A0", "Pixel"));
        assertEquals("Unknown", BatteryTelemetry.deviceName("", "\n"));
    }

    private static void testCurrentSourceUnitsAndFallbacks() {
        final List<String> attempts = new ArrayList<String>();
        Long value = CurrentReader.getValue("generic", new CurrentReader.SourceReader() {
            @Override
            public Long read(String path, int divisor) {
                attempts.add(path + ":" + divisor);
                if (path.equals("/sys/devices/platform/ds2784-battery/getcurrent")) {
                    return Long.valueOf(Long.MAX_VALUE);
                }
                if (path.equals("/sys/class/power_supply/battery/current_now")) {
                    return Long.valueOf(-321L);
                }
                return null;
            }
        });

        assertEquals(Long.valueOf(-321L), value);
        assertTrue(attempts.size() > 1);
        assertEquals("/sys/devices/platform/ds2784-battery/getcurrent:1000", attempts.get(0));
        assertTrue(attempts.contains("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/ds2746-battery/current_now:1000"));
        assertTrue(attempts.contains("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/battery/current_now:1000"));
        assertTrue(attempts.contains("/sys/class/power_supply/battery/current_now:1000"));
        assertTrue(!attempts.contains("/sys/class/power_supply/max17042-0/current_now:1"));
    }

    private static void testOneLineParsing() {
        File source = null;
        try {
            source = File.createTempFile("battery-current", ".txt");
            FileWriter writer = new FileWriter(source);
            writer.write(" 1234567 \nignored\n");
            writer.close();
            assertEquals(Long.valueOf(1234L), OneLineReader.getValue(source, 1000));

            writer = new FileWriter(source);
            writer.write("not-a-number\n");
            writer.close();
            assertEquals(null, OneLineReader.getValue(source, 1));
        } catch (Exception failure) {
            throw new AssertionError(failure);
        } finally {
            if (source != null) {
                source.delete();
            }
        }
    }

    private static void testReceiverDeliveryBoundaries() {
        final List<Intent> deliveries = new ArrayList<Intent>();
        mBatInfoReceiver receiver = new mBatInfoReceiver(
                new mBatInfoReceiver.BatteryStatusListener() {
                    @Override
                    public void onBatteryStatusChanged(Intent batteryStatus) {
                        deliveries.add(batteryStatus);
                    }
                });
        Intent batteryStatus = new Intent();

        receiver.onReceive(null, batteryStatus);
        assertEquals(1, deliveries.size());
        assertTrue(deliveries.get(0) == batteryStatus);

        receiver.onReceive(null, null);
        assertEquals(1, deliveries.size());

        new mBatInfoReceiver(null).onReceive(null, batteryStatus);
        assertEquals(1, deliveries.size());
    }

    private static void assertTrue(boolean condition) {
        assertions++;
        if (!condition) {
            throw new AssertionError("expected true");
        }
    }

    private static void assertEquals(Object expected, Object actual) {
        assertions++;
        if (expected == null ? actual != null : !expected.equals(actual)) {
            throw new AssertionError("expected " + expected + " but was " + actual);
        }
    }
}
