package npcs;

import flixel.FlxG;
import flixel.FlxObject;
import npcs.npcs.EnemyChaser;
/**
 * ...
 * @author ...
 */

class NpcConditions 
{

public static function idle(Owner:EnemyChaser)
	{
		return(!Owner.seePlayer);
	}

	public static function see(Owner:EnemyChaser)
	{
		return(Owner.seePlayer && !Owner._isFearable);
	}
	
	public static function dead(Owner:EnemyChaser)
	{
		return(Owner._health <= 0);
	}
	
	public static function suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion > 20 && !Owner._suspicious);
	}
	
	public static function very_suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion > 50 && Owner._suspicious);
	}
	
	public static function not_very_suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 40);
	}
	
	public static function notsuspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 15);
	}
	
	public static function fear(Owner:EnemyChaser)
	{
		return(Owner._suspicion < 20 && Owner._isFearable && Owner.seePlayer);
	}
	
	public static function calm_down(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 5 && Owner._isFearable && !Owner.seePlayer);
	}
	
}