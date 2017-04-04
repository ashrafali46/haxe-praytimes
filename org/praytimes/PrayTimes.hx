package org.praytimes;

import org.praytimes.Times;
import org.praytimes.constants.CalculationMethod;
import org.praytimes.constants.HighLatMethod;
import org.praytimes.constants.JuristicMethod;
import org.praytimes.constants.MidnightMode;
import org.praytimes.constants.Time;
import org.praytimes.utils.DMath;

//--------------------- Copyright Block ----------------------
/*

	PrayTimes.js: Prayer Times Calculator (ver 2.3)
	Copyright (C) 2007-2011 PrayTimes.org

	Developer: Hamid Zarrabi-Zadeh
	License: GNU LGPL v3.0

	TERMS OF USE:
	Permission is granted to use this code, with or
	without modification, in any website or application
	provided that credit is given to the original work
	with a link back to PrayTimes.org.

	This program is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY.

	PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.

	*/

//--------------------- Help and Manual ----------------------
/*

	User's Manual:
	http://praytimes.org/manual

	Calculation Formulas:
	http://praytimes.org/calculation

	//------------------------ User Interface -------------------------

	getTimes (date, coordinates [, timeZone [, dst [, timeFormat]]])

	setMethod (method)       // set calculation method
	adjust (parameters)      // adjust calculation parameters
	tune (offsets)           // tune times by given offsets

	getMethod ()             // get calculation method
	getSetting ()            // get current calculation parameters
	getOffsets ()            // get current time offsets

	//------------------------- Sample Usage --------------------------

	var PT = new PrayTimes('ISNA');
	var times = PT.getTimes(new Date(), [43, -80], -5);
	document.write('Sunrise = '+ times.sunrise)

	*/

class PrayTimes
{
	private var numIterations : Int = 1;
	private var calculationMethod : CalculationMethod;
	//private var offset:Object;

	// coordinates
	private var lat : Float;
	private var lng : Float;
	private var elv : Float;
	private var highLats : String;
	// time variables
	private var timeZone : Float;
	private var jDate : Float;
	private var date : Date;

	public function new(calculationMethod : CalculationMethod, lat : Float, lng : Float, elv : Float = 0, timeZone : Float = 0, highLats : String = "NightMiddle")
	{
		this.calculationMethod = calculationMethod;
		this.lat = lat;
		this.lng = lng;
		this.elv = elv;
		this.timeZone = timeZone;
		this.highLats = highLats;
	}

	/*
		//----------------------- Public Functions ------------------------

		// set calculation method
		setMethodprivate function  (method) {
			if (methods[method]) {
				this.adjust(methods[method].params);
				calculationMethod = method;
			}
		}

		// set calculating parameters
		adjustprivate function  (params) {
			for (var id in params)
				setting[id] = params[id];
		}

		// set time offsets
		tuneprivate function  (timeOffsets) {
			for (var i in timeOffsets)
				offset[i] = timeOffsets[i];
		}

		// get current calculation method
		getMethodprivate function  () { return calculationMethod; },

		// get current setting
		getSettingprivate function  () { return setting; },

		// get current time offsets
		getOffsetsprivate function  () { return offset; },

		// get default calc parametrs
		getDefaultsprivate function  () { return methods; },
		*/

	// return prayer times for a given date
	public function getTimes(date : Date = null) : Times
	{
		/*, dst*/
		if (date == null)
			date = Date.now();
		this.date = date;

		//timeZone = timeZone==0 ? - date.getTimezoneOffset() / 60 : timeZone;
		jDate = this.julian(date.getFullYear(), date.getMonth()+ 1, date.getDate()) - lng / (15 * 24);
		return this.computeTimes();
	}

	//---------------------- Calculation Functions -----------------------

	// compute mid-day time
	private function midDay(time : Float) : Float
	{
		var eqt : Float = this.sunPosition(jDate + time).equation;
		var noon : Float = DMath.fixHour(12 - eqt);
		return noon;
	}

	// compute the time at which sun reaches a specific angle below horizon
	private function sunAngleTime(angle : Float, time : Float, direction : String = "cw") : Float
	{
		var decl : Float = this.sunPosition(jDate + time).declination;
		var noon : Float = this.midDay(time);
		var t : Float = 1 / 15 * DMath.arccos((-DMath.sin(angle) - DMath.sin(decl) * DMath.sin(lat)) / (DMath.cos(decl) * DMath.cos(lat)));
		return noon + ((direction == "ccw") ? -t : t);
	}

	// compute asr time
	private function asrTime(factor : Float, time : Float) : Float
	{
		var decl : Float = this.sunPosition(jDate + time).declination;
		var angle : Float = -DMath.arccot(factor + DMath.tan(Math.abs(lat - decl)));
		return sunAngleTime(angle, time);
	}

	// compute declination angle of sun and equation of time
	// Ref: http://aa.usno.navy.mil/faq/docs/SunApprox.php
	private function sunPosition(jd : Float) : Position
	{
		var D : Float = jd - 2451545.0;
		var g : Float = DMath.fixAngle(357.529 + 0.98560028 * D);
		var q : Float = DMath.fixAngle(280.459 + 0.98564736 * D);
		var L : Float = DMath.fixAngle(q + 1.915 * DMath.sin(g) + 0.020 * DMath.sin(2 * g));

		var R : Float = 1.00014 - 0.01671 * DMath.cos(g) - 0.00014 * DMath.cos(2 * g);
		var e : Float = 23.439 - 0.00000036 * D;

		var RA : Float = DMath.arctan2(DMath.cos(e) * DMath.sin(L), DMath.cos(L)) / 15;
		var eqt : Float = q / 15 - DMath.fixHour(RA);
		var decl : Float = DMath.arcsin(DMath.sin(e) * DMath.sin(L));

		return new Position(decl, eqt);
	}

	// convert Gregorian date to Julian day
	// Ref: Astronomical Algorithms by Jean Meeus
	private function julian(year : Float, month : Float, day : Float) : Float
	{
		if (month <= 2)
		{
			year -= 1;
			month += 12;
		}
		var A : Float = Math.floor(year / 100);
		var B : Float = 2 - A + Math.floor(A / 4);

		return Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + day + B - 1524.5;
	}

	//---------------------- Compute Prayer Times -----------------------

	// compute prayer times at given julian date
	private function computePrayerTimes(times : Times) : Times
	{
		times = this.dayPortion(times);

		var ret : Times = new Times(times.date);

		ret.__times[Time.fajr] = this.sunAngleTime(calculationMethod.fajrAngle, times.__times[Time.fajr], "ccw");
		ret.__times[Time.sunrise] = this.sunAngleTime(this.riseSetAngle(), times.__times[Time.sunrise], "ccw");
		ret.__times[Time.dhuhr] = this.midDay(times.__times[Time.dhuhr]);
		ret.__times[Time.asr] = this.asrTime(this.asrFactor(calculationMethod.asrMethod), times.__times[Time.asr]);
		ret.__times[Time.sunset] = this.sunAngleTime(this.riseSetAngle(), times.__times[Time.sunset]);
		ret.__times[Time.maghrib] = this.sunAngleTime(calculationMethod.maghribAngle, times.__times[Time.maghrib]);
		ret.__times[Time.isha] = this.sunAngleTime(calculationMethod.ishaAngle, times.__times[Time.isha]);

		return ret;
	}

	// compute prayer times
	private function computeTimes() : Times
	{
		// default times
		var times : Times = new Times(date);

		// main iterations
		for (i in 1...numIterations + 1)
			times = this.computePrayerTimes(times);

		times = this.adjustTimes(times);

		// add midnight time
		times.__times[Time.midnight] = ((calculationMethod.midnightMethod == MidnightMode.JAFARI)) ? times.__times[Time.sunset] + this.timeDiff(times.__times[Time.sunset], times.__times[Time.fajr]) / 2 : times.__times[Time.sunset] + this.timeDiff(times.__times[Time.sunset], times.__times[Time.sunrise]) / 2;

		times = this.tuneTimes(times);
		return this.modifyFormats(times);
	}

	// adjust times
	private function adjustTimes(times : Times) : Times
	{
		//var params = setting;
		for (t in times.__times.keys())
			times.__times[t] += timeZone - lng / 15;

		if (highLats != HighLatMethod.NONE)
			times = this.adjustHighLats(times);

		/*if (this.isMin(params.imsak))
		times.imsak = times.fajr- this.eval(params.imsak)/ 60;
		if (this.isMin(params.maghrib))
		times.maghrib = times.sunset+ this.eval(params.maghrib)/ 60;
		if (this.isMin(params.isha))
		times.isha = times.maghrib+ this.eval(params.isha)/ 60;
		times.dhuhr += this.eval(params.dhuhr)/ 60; */

		times.__times[Time.imsak] = times.__times[Time.fajr] - calculationMethod.imsakOffset / 60;

		if (!Math.isNaN(calculationMethod.maghribOffset))
			times.__times[Time.maghrib] = times.__times[Time.sunset] + calculationMethod.maghribOffset / 60;

		if (!Math.isNaN(calculationMethod.ishaOffset))
			times.__times[Time.isha] = times.__times[Time.maghrib]+ calculationMethod.ishaOffset / 60;

		times.__times[Time.dhuhr] += calculationMethod.dhuhrOffset / 60;

		return times;
	}

	// get asr shadow factor
	private function asrFactor(asrParam : String) : Float
	{
		return (asrParam == JuristicMethod.HANAFI) ? 2 : 1;
	}

	// return sun angle for sunset/sunrise
	private function riseSetAngle() : Float
	{
		//var earthRad = 6371009; // in meters
		//var angle = DMath.arccos(earthRad/(earthRad+ elv));
		var angle : Float = 0.0347 * Math.sqrt(elv);  // an approximation
		return 0.833 + angle;
	}

	// apply offsets to the times
	private function tuneTimes(times : Times) : Times
	{
		//for each(var t:Number in times.values)
		//	times[i] += offset[i]/ 60;
		return times;
	}

	// convert times to given time format
	private function modifyFormats(times : Times) : Times
	{
		//for each(var t:Number in times.values)
		//	t = this.getFormattedTime(t, timeFormat);
		return times;
	}

	// adjust times for locations in higher latitudes
	private function adjustHighLats(times : Times) : Times
	{
		var nightTime : Float = this.timeDiff(times.__times[Time.sunset], times.__times[Time.sunrise]);

		times.__times[Time.imsak] = this.adjustHLTime(times.__times[Time.imsak], times.__times[Time.sunrise], calculationMethod.imsakOffset, nightTime, "ccw");
		times.__times[Time.fajr] = this.adjustHLTime(times.__times[Time.fajr], times.__times[Time.sunrise], calculationMethod.fajrAngle, nightTime, "ccw");
		times.__times[Time.isha] = this.adjustHLTime(times.__times[Time.isha], times.__times[Time.sunset], calculationMethod.ishaAngle, nightTime);
		times.__times[Time.maghrib] = this.adjustHLTime(times.__times[Time.maghrib], times.__times[Time.sunset], calculationMethod.maghribAngle, nightTime);

		return times;
	}

	// adjust a time for higher latitudes
	private function adjustHLTime(time : Float, base : Float, angle : Float, night : Float, direction : String = "cw") : Float
	{
		var portion : Float = this.nightPortion(angle, night);
		var timeDif : Float = ((direction == "ccw")) ? timeDiff(time, base) : timeDiff(base, time);
		if (Math.isNaN(time) || timeDif > portion)
			time = base + ((direction == "ccw") ? -portion : portion);
		return time;
	}

	// the night portion used for adjusting times in higher latitudes
	private function nightPortion(angle : Float, night : Float) : Float
	{
		var portion : Float = 0.5;  // MidNight
		if (highLats == HighLatMethod.ANGLE_BASED)
			portion = 1 / 60 * angle
			else if (highLats == HighLatMethod.ONE_SEVENTH)
				portion = 1 / 7;
		return portion * night;
	}

	// convert hours to day portions
	private function dayPortion(times : Times) : Times
	{
		for (t in times.__times.keys())
			times.__times[t] /= 24;
		return times;
	}

	/*
		//---------------------- Time Zone Functions -----------------------

		// get local time zone
		getTimeZoneprivate function  (date) {
			var year = date[0];
			var t1 = this.gmtOffset([year, 0, 1]);
			var t2 = this.gmtOffset([year, 6, 1]);
			return Math.min(t1, t2);
		},

		// get daylight saving for a given date
		getDstprivate function  (date) {
			return 1* (this.gmtOffset(date) != this.getTimeZone(date));
		},

		// GMT offset for a given date
		gmtOffsetprivate function  (date) {
			var localDate = new Date(date[0], date[1]- 1, date[2], 12, 0, 0, 0);
			var GMTString = localDate.toGMTString();
			var GMTDate = new Date(GMTString.substring(0, GMTString.lastIndexOf(' ')- 1));
			var hoursDiff = (localDate- GMTDate) / (1000* 60* 60);
			return hoursDiff;
		},
		*/

	//---------------------- Misc Functions -----------------------

	// convert given string into a number
	/*private function eval(str) : Float
	{
	    return 1 * (str + "").split(new EReg('[^0-9.+-]', ""))[0];
	}*/

	// detect if input contains 'min'
	/*private function isMin (arg) : Boolean
		{
			return String(arg).indexOf("min") != -1;
		}*/

	// compute the difference between two times
	private function timeDiff(time1 : Float, time2 : Float) : Float
	{
		return DMath.fixHour(time2 - time1);
	}
}

class Position
{
	public var declination : Float;
	public var equation : Float;

	@:allow(org.praytimes)
	private function new(declination : Float, equation : Float)
	{
		this.declination = declination;
		this.equation = equation;
	}
}
