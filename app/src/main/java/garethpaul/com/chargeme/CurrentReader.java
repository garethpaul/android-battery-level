package garethpaul.com.chargeme;

/*
 *  Copyright (c) 2010-2011 Ran Manor
 *
 *  This file is part of CurrentWidget.
 *
 *  CurrentWidget is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  CurrentWidget is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with CurrentWidget.  If not, see <http://www.gnu.org/licenses/>.
*/

import java.io.File;
import java.util.Locale;

import android.os.Build;

public class CurrentReader {
    interface SourceReader {
        Long read(String path, int divisor);
    }

    private static final String SMEM_PATH = "/sys/class/power_supply/battery/smem_text";

    static public Long getValue() {
        return getValue(Build.MODEL, new SourceReader() {
            @Override
            public Long read(String path, int divisor) {
                File source = new File(path);
                if (!source.exists()) {
                    return null;
                }
                if (SMEM_PATH.equals(path)) {
                    return SMemTextReader.getValue(source);
                }
                return OneLineReader.getValue(source, divisor);
            }
        });
    }

    static Long getValue(String deviceModel, SourceReader sourceReader) {
        String model = deviceModel == null ? "" : deviceModel.toLowerCase(Locale.US);
        if (model.contains("desire hd") ||
                model.contains("desire z") ||
                model.contains("inspire")) {
            Long value = read(sourceReader,
                    "/sys/class/power_supply/battery/batt_current", 1);
            if (BatteryTelemetry.isCurrentPlausible(value)) {
                return value;
            }
        }

        String[] paths = {
                "/sys/devices/platform/ds2784-battery/getcurrent",
                "/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/ds2746-battery/current_now",
                "/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/battery/current_now",
                SMEM_PATH,
                "/sys/class/power_supply/battery/batt_current",
                "/sys/class/power_supply/battery/current_now",
                "/sys/class/power_supply/battery/batt_chg_current",
                "/sys/class/power_supply/battery/charger_current",
                "/sys/class/power_supply/max17042-0/current_now"
        };
        int[] divisors = {1000, 1000, 1000, 1, 1, 1000, 1, 1, 1000};
        for (int index = 0; index < paths.length; index++) {
            Long value = read(sourceReader, paths[index], divisors[index]);
            if (BatteryTelemetry.isCurrentPlausible(value)) {
                return value;
            }
        }

        return null;
    }

    private static Long read(SourceReader sourceReader, String path, int divisor) {
        if (sourceReader == null) {
            return null;
        }
        return sourceReader.read(path, divisor);
    }
}
