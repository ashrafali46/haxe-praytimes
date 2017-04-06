package org.praytimes;

import org.praytimes.constants.Time;
import org.praytimes.utils.DMath;

enum Format
{
	h24; h12; hns12; float; 
}

enum Suffix
{
	am; pm;
}

class Times
{

	
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

	public function toTimeFormatString(format : Format = null) : String
	{
		if (format == null)
			format = Format.h24;
			
		var ret:String = "";
		for (t in __times.keys())
			ret += t + ":" + getFormattedTime(__times[t], format) + (t==Time.midnight?"":", ") ;
		return ret;
	}
	
	// convert float time to the given format (see timeFormats)
	public static function getFormattedTime(time : Float, format : Format = null) : String
	{
		if (format == null)
			format = Format.h24;
		
		if (Math.isNaN(time))
			return "--Invalid time--";

		if (format == Format.float)
			return Std.string(time);

		time = DMath.fixHour(time + 0.5 / 60);  // add 0.5 minutes to round
		var hours : Float = Math.floor(time);
		var minutes : Float = Math.floor((time - hours) * 60);
		var suffix : String = format == Format.h12 ? ((hours < 12) ? Suffix.am.getName() : Suffix.pm.getName()) : "";
		var hour : String = format == Format.h24 ? twoDigitsFormat(hours) : Std.string(((hours + 12 - 1) % 12 + 1));
		return hour + ":" + twoDigitsFormat(minutes) + ((suffix != null) ? " " + suffix : "");
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