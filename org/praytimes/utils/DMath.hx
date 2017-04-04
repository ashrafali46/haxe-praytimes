package org.praytimes.utils;


class DMath
{
    //---------------------- Degree-Based Math Class -----------------------
    
    public static function dtr(d : Float) : Float{return (d * Math.PI) / 180.0;
    }
    public static function rtd(r : Float) : Float{return (r * 180.0) / Math.PI;
    }
    
    public static function sin(d : Float) : Float{return Math.sin(dtr(d));
    }
    public static function cos(d : Float) : Float{return Math.cos(dtr(d));
    }
    public static function tan(d : Float) : Float{return Math.tan(dtr(d));
    }
    
    public static function arcsin(d : Float) : Float{return rtd(Math.asin(d));
    }
    public static function arccos(d : Float) : Float{return rtd(Math.acos(d));
    }
    public static function arctan(d : Float) : Float{return rtd(Math.atan(d));
    }
    
    public static function arccot(x : Float) : Float{return rtd(Math.atan(1 / x));
    }
    public static function arctan2(y : Float, x : Float) : Float{return rtd(Math.atan2(y, x));
    }
    
    public static function fixAngle(a : Float) : Float{return fix(a, 360);
    }
    public static function fixHour(a : Float) : Float{return fix(a, 24);
    }
    
    public static function fix(a : Float, b : Float) : Float{a = a - b * Math.floor(a / b);return ((a < 0)) ? a + b : a;
    }

    public function new()
    {
    }
}
