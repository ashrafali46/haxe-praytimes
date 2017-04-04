as3-praytimes
=============

Pray Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities.

The code is originally written in JavaScript. This manual provides information on how to use the code on a web-page or a [JavaScript-based](http://praytimes.org/manual/) application to display prayer times.


<b>CalculationMethod:</b><br/>
   Muslim World League<br/>
   Islamic Society of North America (ISNA)<br/>	
   Egyptian General Authority of Survey<br/>
   Umm al-Qura University, Makkah<br/>
   120 min during Ramadan<br/>
   University of Islamic Sciences, Karachi<br/>
   Institute of Geophysics, University of Tehran<br/>	
   Shia Ithna Ashari, Leva Research Institute, Qum<br/>

<b>Latitude of your city<br/>
Longitude of your city<br/>
Rise Angle :</b> for sunrise and sunset offset default value is 0.833 + sun angle<br/> 
<b>Time Zone : </b>for example in Tehran, first half year is 4.5 and other months is 3.5<br/>
<b>HighLats :</b><br/>
   Middle of night<br/>
   Angle/60th of night<br/>
   1/7th of night<br/>
   No adjustment<br/>

Install via 
`haxelib git praytimes https://github.com/manjav/haxe-praytimes`

Add to `project.xml`:

```xml
<haxelib name="praytimes" if="android" />
```

```Haxe
var pt:PrayTimes = new PrayTimes(CalculationMethod.TEHRAN, 35.6961, 51.4231, 0, 4.5);
var dts:Array<Date> = pt.getTimes().toDates();
trace(pt.getTimes().toTimeFormatString());
for (d in dts)
	trace(d);
	
//Main.hx:23: imsak:05:14 , fajr:05:24 , sunrise:06:50 , dhuhr:13:08 , asr:16:42 , sunset:19:27 , maghrib:19:45 , isha:20:33 , midnight:00:25 
//Main.hx:25: 2017-04-02 05:14:04
//Main.hx:25: 2017-04-02 05:24:04
//Main.hx:25: 2017-04-02 06:49:31
//Main.hx:25: 2017-04-02 13:07:52
//Main.hx:25: 2017-04-02 16:42:09
//Main.hx:25: 2017-04-02 19:26:46
//Main.hx:25: 2017-04-02 19:45:01
//Main.hx:25: 2017-04-02 20:32:49
//Main.hx:25: 2017-04-03 00:25:25


```
