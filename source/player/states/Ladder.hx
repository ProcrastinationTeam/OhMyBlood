package player.states;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

/**
 * ...
 * @author ...
 */

 
class Ladder extends FlxFSMState<Player>
{

	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("LADDER STATE");
		owner.acceleration.y = 0;
		//owner.velocity.y = 0;
		//owner.velocity.x = 0;
		
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		if (FlxG.keys.pressed.UP)
		{
			owner.velocity.y = -40;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			
			owner.velocity.y = 40;
		}
		else
		{
			owner.acceleration.y = 0;
			owner.velocity.y = 0.0;
		}
		
		if (FlxG.keys.pressed.LEFT)
		{
			owner.velocity.x = -25;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			
			owner.velocity.x = 25;
		}
		else
		{
			owner.acceleration.x = 0;
			owner.velocity.x = 0.0;
		}
		
	}
	
	override public function exit(owner: Player):Void
	{
		owner.acceleration.y = owner.GRAVITY;
	}
}