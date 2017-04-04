package org.praytimes.constants;


class CalculationMethod
{
    /**Muslim World League*/
    public static var MWL : CalculationMethod = new CalculationMethod("MWL", 18, 17);
    
    /**Islamic Society of North America (ISNA)*/
    public static var ISNA : CalculationMethod = new CalculationMethod("ISNA", 15, 15);
    
    /**gyptian General Authority of Survey*/
    public static var EGYPT : CalculationMethod = new CalculationMethod("Egypt", 19.5, 17.5);
    
    /**Umm Al-Qura University, Makkah<br>Fajr was 19 degrees before 1430 hijri*/
    public static var MAKKAH : CalculationMethod = new CalculationMethod("Makkah", 18.5, 0);  //90 min  
    
    /**University of Islamic Sciences, Karachi*/
    public static var KARACHI : CalculationMethod = new CalculationMethod("Karachi", 18, 18);
    
    /**Institute of Geophysics, University of Tehran<br>Isha is not explicitly specified in this method*/
    public static var TEHRAN : CalculationMethod = new CalculationMethod("Tehran", 17.7, 14, 4.5, "Jafari");
    
    /**Shia Ithna-Ashari, Leva Institute, Qum*/
    public static var JAFARI : CalculationMethod = new CalculationMethod("Jafari", 16, 14, 4, "Jafari");
    
    
    public var name : String;
    public var fajrAngle : Float;
    public var ishaAngle : Float;
    public var ishaOffset : Float = 0;
    public var maghribAngle : Float = 0;
    public var maghribOffset : Float = 0;
    public var imsakOffset : Float = 10;
    public var dhuhrOffset : Float = 0;
    public var asrMethod : JuristicMode = JuristicMode.standard;
    public var midnightMethod : String = "Standard";
    
    public function new(name : String, fajrAngle : Float, ishaAngle : Float, maghribAngle : Float = 0, midnightMethod : String = "Standard")
    {
        this.name = name;
        this.fajrAngle = fajrAngle;
        this.ishaAngle = ishaAngle;
        this.maghribAngle = maghribAngle;
        this.midnightMethod = midnightMethod;
        
        if (ishaAngle != 0) 
            ishaOffset = Math.NaN;
        
        if (maghribAngle != 0) 
            maghribOffset = Math.NaN;
        
        if (name == "Makkah") 
            ishaOffset = 90;
    }
}
