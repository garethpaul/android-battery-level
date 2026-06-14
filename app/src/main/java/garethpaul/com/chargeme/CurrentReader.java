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

    private static Long readOneLineCurrent(File source, boolean convertToMillis) {
        if (!source.exists()) {
            return null;
        }

        return OneLineReader.getValue(source, convertToMillis);
    }

    static public Long getValue() {

        File f = null;
        Long value = null;

        // htc desire hd / desire z / inspire?
        String deviceModel = Build.MODEL;
        String model = deviceModel == null ? "" : deviceModel.toLowerCase(Locale.US);
        if (model.contains("desire hd") ||
                model.contains("desire z") ||
                model.contains("inspire")) {

            f = new File("/sys/class/power_supply/battery/batt_current");
            value = readOneLineCurrent(f, false);
            if (value != null) {
                return value;
            }
        }

        // nexus one cyangoenmod
        f = new File("/sys/devices/platform/ds2784-battery/getcurrent");
        value = readOneLineCurrent(f, true);
        if (value != null) {
            return value;
        }

        // sony ericsson xperia x1
        f = new File("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/ds2746-battery/current_now");
        value = readOneLineCurrent(f, false);
        if (value != null) {
            return value;
        }

        // xdandroid
        /*if (Build.MODEL.equalsIgnoreCase("MSM")) {*/
        f = new File("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/battery/current_now");
        value = readOneLineCurrent(f, false);
        if (value != null) {
            return value;
        }
        /*}*/

        // droid eris
        f = new File("/sys/class/power_supply/battery/smem_text");
        if (f.exists()) {
            value = SMemTextReader.getValue();
            if (value != null)
                return value;
        }

        // some htc devices
        f = new File("/sys/class/power_supply/battery/batt_current");
        value = readOneLineCurrent(f, false);
        if (value != null)
            return value;

        // nexus one
        f = new File("/sys/class/power_supply/battery/current_now");
        value = readOneLineCurrent(f, true);
        if (value != null)
            return value;

        // samsung galaxy vibrant
        f = new File("/sys/class/power_supply/battery/batt_chg_current");
        value = readOneLineCurrent(f, false);
        if (value != null)
            return value;

        // sony ericsson x10
        f = new File("/sys/class/power_supply/battery/charger_current");
        value = readOneLineCurrent(f, false);
        if (value != null)
            return value;

        // Nook Color
        f = new File("/sys/class/power_supply/max17042-0/current_now");
        value = readOneLineCurrent(f, false);
        if (value != null)
            return value;

        return null;
    }
}
