package source;
// source Pew.hx


import flixel.FlxObject;

class Pew {
    // Returns first object of a, if point(x, y) will hit the hitbox.
    public static function isHit(x:Float, y:Float, a:Array<FlxObject>):FlxObject {
        if (a != null && a.length > 0) {
            for (o in a) {
                if (x >= o.x&&x <= o.x+o.width&&y >= o.y&&y <=o.y+o.height) {
                    return o;
                }
              }
          }
          return null;
      }

      // shoot from point (sx, sy) to (ex, ex) if will return the first hit a.
      public static function shoot(sx:Float, sy:Float, ex:Float, ey:Float, a:Array<FlxObject>=null):FlxObject {
          var dx:Float    = ex - sx;
          var dy:Float    = ey - sy;
          if (a == null || a.length == 0) {
              return null;
          }
          if (dx >= 0) {
              if (_p(dx) > _p(dy)) {
                  return _shootHor(sx, sy, ex, ey, a, false);
              } else {
                  return _shootVer(sx, sy, ex, ey, a, false);
             }
          } else {
              if (_p(dx) > _p(dy)) {
                  return _shootHor(ex, ey, sx, sy, a, true);
              } else {
                  return _shootVer(ex, ey, sx, sy, a, true);
              }
          }
          return null;
      }

      // return positive value;
      private static function _p(v:Float) {
          if (v < 0) { return 0 - v; } return v;
      }

      // Make a vertical line and return first hit object
      private static function _shootVer(sx:Float, sy:Float, ex:Float, ey:Float, a:Array<FlxObject>, reverse:Bool=false):FlxObject {
          var r:FlxObject;
          var dx=Math.abs(sx - ex),dy=Math.abs(sy - ey);
          var p=(2*dy-dx),x=sx,y=sy,e=ex,inc=1;
          if (sy > ey) { x=ex; y=ey; e = sy; }
          if (sx > ex) { inc=1; }
          if (reverse){ inc=-1; }
          while (y <= e) {
              if ((r=isHit(x, y++, a))!=null) { return r; }
              if (p <= 0) {
                  p+=2*dx;
              } else {
                  x+=inc;p+=(2*(dx-dy));
              }
          }
          return null;
      }

      // Make a horizontal line and return first hit object
      private static function _shootHor(sx:Float, sy:Float, ex:Float, ey:Float, a:Array<FlxObject>, reverse:Bool=false):FlxObject {
          var r:FlxObject;
          var dx=Math.abs(sx - ex),dy=Math.abs(sy - ey);
          var p=(2*dy-dx),x=sx,y=sy,e=ex,inc=1;
          if (sx > ex) { x=ex; y=ey; e=sx; }
          if (sy > ey) { inc=-1; }
          if (reverse) { inc=1; }
          while (x <= e) {
              if ((r=isHit(x++, y, a))!=null) { return r; }
              if (p <= 0) {
                  p+=2*dy;
              } else {
                  y+=inc;p+=(2*(dy-dx));
              }
          }
          return null;
      } 
  }