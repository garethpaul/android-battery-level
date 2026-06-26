package garethpaul.com.chargeme;

import java.util.Locale;

final class BatteryTelemetry {
    private static final String UNKNOWN = "Unknown";
    private static final int MIN_TEMPERATURE_TENTHS = -1000;
    private static final int MAX_TEMPERATURE_TENTHS = 2000;
    private static final int MAX_VOLTAGE_MILLIVOLTS = 100000;
    private static final long MAX_CURRENT_MILLIAMPS = 1000000L;
    private static final int MAX_LABEL_LENGTH = 80;

    private BatteryTelemetry() {
    }

    static int levelPercent(int rawLevel, int scale) {
        if (rawLevel < 0 || scale <= 0) {
            return -1;
        }

        long roundedPercent = ((long) rawLevel * 100L + scale / 2L) / scale;
        return (int) Math.max(0L, Math.min(100L, roundedPercent));
    }

    static String temperatureText(int temperatureTenths) {
        if (temperatureTenths < MIN_TEMPERATURE_TENTHS
                || temperatureTenths > MAX_TEMPERATURE_TENTHS) {
            return UNKNOWN;
        }

        return String.format(Locale.US, "%.1f \u2103", temperatureTenths / 10.0d);
    }

    static String voltageText(int millivolts) {
        if (millivolts <= 0 || millivolts > MAX_VOLTAGE_MILLIVOLTS) {
            return UNKNOWN;
        }

        return String.format(Locale.US, "%.1fV", millivolts / 1000.0d);
    }

    static boolean isCurrentPlausible(Long currentValue) {
        return currentValue != null
                && currentValue.longValue() >= -MAX_CURRENT_MILLIAMPS
                && currentValue.longValue() <= MAX_CURRENT_MILLIAMPS;
    }

    static String currentText(Long currentValue) {
        if (!isCurrentPlausible(currentValue)) {
            return UNKNOWN;
        }

        return String.valueOf(currentValue.longValue());
    }

    static String normalizedLabel(String value) {
        if (value == null) {
            return UNKNOWN;
        }

        String normalized = value.trim();
        if (normalized.length() == 0 || normalized.length() > MAX_LABEL_LENGTH) {
            return UNKNOWN;
        }

        boolean hasVisibleContent = false;
        for (int index = 0; index < normalized.length();) {
            int codePoint = normalized.codePointAt(index);
            if (Character.isISOControl(codePoint)
                    || Character.getType(codePoint) == Character.FORMAT) {
                return UNKNOWN;
            }
            if (!isInvisibleLabelCodePoint(codePoint)) {
                hasVisibleContent = true;
            }
            index += Character.charCount(codePoint);
        }

        return hasVisibleContent ? normalized : UNKNOWN;
    }

    static String deviceName(String manufacturerValue, String modelValue) {
        if (hasRejectedContent(manufacturerValue) || hasRejectedContent(modelValue)) {
            return UNKNOWN;
        }
        String manufacturer = normalizedOptionalLabel(manufacturerValue);
        String model = normalizedOptionalLabel(modelValue);
        if (manufacturer == null && model == null) {
            return UNKNOWN;
        }
        if (manufacturer == null) {
            return capitalize(model);
        }
        if (model == null) {
            return capitalize(manufacturer);
        }
        if (model.toLowerCase(Locale.US).startsWith(manufacturer.toLowerCase(Locale.US))) {
            return capitalize(model);
        }
        return capitalize(manufacturer) + " " + capitalize(model);
    }

    private static String normalizedOptionalLabel(String value) {
        String normalized = normalizedLabel(value);
        return UNKNOWN.equals(normalized) ? null : normalized;
    }

    private static boolean hasRejectedContent(String value) {
        return value != null
                && value.trim().length() > 0
                && UNKNOWN.equals(normalizedLabel(value));
    }

    private static boolean isInvisibleLabelCodePoint(int codePoint) {
        return Character.isWhitespace(codePoint)
                || Character.isSpaceChar(codePoint)
                || codePoint == 0x034F
                || (codePoint >= 0x180B && codePoint <= 0x180D)
                || (codePoint >= 0xFE00 && codePoint <= 0xFE0F)
                || (codePoint >= 0xE0100 && codePoint <= 0xE01EF);
    }

    private static String capitalize(String value) {
        if (value == null || value.length() == 0 || Character.isUpperCase(value.charAt(0))) {
            return value;
        }
        return Character.toUpperCase(value.charAt(0)) + value.substring(1);
    }
}
