package org.praytimes;

import org.praytimes.constants.Time;
import org.praytimes.utils.DMath;

class Times
{
	/**24-hour format<br>Value: "24h"*/
	public static inline var FORMAT_H24 : String = "24h";
	/**12-hour format<br>Value: "12h"*/
	public static inline var FORMAT_H12 : String = "12h";
	/**12-hour format with no suffix<br>Value: "12hNS"*/
	public static inline var FORMAT_HNS12 : String = "12hNS";
	/**floating point number<br>Value: "Float"*/
	public static inline var FORMAT_FLOAT : String = "Float";

	public static inline var SUFFIXES_AM : String = "am";
	public static inline var SUFFIXES_PM : String = "pm";

	// convert float time to the given format (see timeFormats)
	public static function getFormattedTime(time : Float, format : String = "24h") : String
	{
		if (Math.isNaN(time))
			return "--Invalid time--";

		if (format == FORMAT_FLOAT)
			return Std.string(time);

		time = DMath.fixHour(time + 0.5 / 60);  // add 0.5 minutes to round
		var hours : Float = Math.floor(time);
		var minutes : Float = Math.floor((time - hours) * 60);
		var suffix : String = ((format == "12h")) ? (hours < 12) ? SUFFIXES_AM : SUFFIXES_PM : "";
		var hour : String = ((format == "24h")) ? twoDigitsFormat(hours) : Std.string(((hours + 12 - 1) % 12 + 1));
		return hour + ":" + twoDigitsFormat(minutes) + ((suffix != null) ? " " + suffix : "");
	}

	// add a leading 0 if necessary
	public static function twoDigitsFormat(num : Float) : String
	{
		return ((num < 10)) ? "0" + num : num + "";
	}

	public var __times : Map<Time, Float> = [
			Time.imsak => 5,
			Time.fajr => 5,
			Time.sunrise=> 6,
			Time.dhuhr => 12,
			Time.asr => 13,
			Time.sunset => 18,
			Time.maghrib=> 18,
			Time.isha=> 10,
			Time.midnight => 0
											];

	public var date : Date;

	public function new(date : Date)
	{
		this.date = date;
	}

	public function toString() : String
	{
		return "imsak: " + imsak + ", fajr: " + fajr + ", sunrise: " + sunrise + ", dhuhr: " + dhuhr + ", asr: " + asr + ", sunset: " + sunset + ", maghrib: " + maghrib + ", isha: " + isha + ", midnight: " + midnight;
	}

	public function toTimeFormatString(format : String = "24h") : String
	{
		var ret:String = "";
		for (t in __times.keys())
			ret += t + ":" + getFormattedTime(__times[t], format) + (t==Time.midnight?"":", ") ;
		return ret;
	}

	public function toDates() : Array<Date>
	{
		var ret : Array<Date> = new Array<Date>();
		for (t in __times.keys())
			ret.push(getDate(__times[t]));
		return ret;
	}

	public function getDate(time : Float) : Date
	{
		if (Math.isNaN(time))
			return null;

		var hours:Int = Math.floor(time);
		var minf:Float = (time - hours) * 60;
		var min : Int = Math.floor(minf);
		var secf : Float = (minf - min) * 60;
		var sec : Int = Math.floor(secf);
		//ret.milliseconds = Math.floor((secf - sec) * 1000);

		return new Date(date.getFullYear(), date.getMonth(), date.getDate(), hours, min, sec);
	}

}