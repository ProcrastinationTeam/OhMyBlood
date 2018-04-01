package source.player;

import flixel.FlxG;
import flixel.FlxObject;
import player.Player;

class Conditions
{
	
	public static function grounded(Owner: Player):Bool
	{	
		//return (Owner.isTouching(FlxObject.DOWN) && !Owner.is_climbing);
		return ((!Owner.downRightRay || !Owner.downLeftRay) && !Owner.is_climbing && Owner.dashEnd);
	}
	
	public static function bbIn(Owner:Player):Bool
	{
		return (FlxG.keys.justPressed.CONTROL && !Owner.is_bathing && (Owner.currentLeftTile == 2 || Owner.currentRightTile == 2) && (!Owner.downRightRay || !Owner.downLeftRay));  
	}
	
	public static function bbOut(Owner:Player):Bool
	{
		return (FlxG.keys.justPressed.CONTROL && Owner.is_bathing && (Owner.upRightRay && Owner.upLeftRay));  
	}
	
	public static function groundedFromClimb(Owner: Player):Bool
	{	
		//return (Owner.isTouching(FlxObject.DOWN) && (FlxG.keys.justReleased.C));
		return ((!Owner.downRightRay || !Owner.downLeftRay) && (FlxG.keys.justReleased.C));
	}
	
	public static function jump(Owner: Player):Bool
	{
		return (FlxG.keys.justPressed.SPACE && (!Owner.downRightRay || !Owner.downLeftRay || !Owner.sideHighRay || !Owner.sideLowRay));
		//return (FlxG.keys.justPressed.SPACE);
	}
	
	public static function fall(Owner: Player):Bool
	{
		return (!Owner.is_sliding &&  Owner.velocity.y > 0);
	}
	
	public static function fallFromClimb(Owner: Player):Bool
	{
		return (Owner.sideHighRay && Owner.sideLowRay);
	}
	
	public static function dash(Owner: Player):Bool
	{
		return (FlxG.keys.justPressed.D && !Owner.has_dashed);
	}
	
	public static function climb(Owner:Player):Bool
	{
		return( FlxG.keys.pressed.C && !Owner.has_jumped  && !Owner.sideHighRay); 
	}
	
	public static function releaseClimb(Owner:Player):Bool
	{
		return(FlxG.keys.justReleased.C); 
	}
	
	public static function slideWall(Owner:Player):Bool
	{
		return ((FlxG.keys.pressed.RIGHT && Owner.isTouching(FlxObject.RIGHT)) || (FlxG.keys.pressed.LEFT && Owner.isTouching(FlxObject.LEFT))) && (Owner.downRightRay || Owner.downLeftRay) && !FlxG.keys.pressed.C && Owner.velocity.y >0;
	}
	
	public static function animationFinished(Owner:Player):Bool
	{
		return Owner.animation.finished;
	}
	
	
	public static function biteEnemy(Owner:Player):Bool
	{
		return false;
	}
	
}