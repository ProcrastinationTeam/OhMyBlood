package source.player.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

class Fall extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : FALL");
		
		if (!owner.has_dashed)
		{
			owner.animation.play("fall");
		}
		else
		{
			owner.animation.play("blueFall");
		}
		//owner.has_dashed = false;
		
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			
			owner.facing = FlxG.keys.pressed.LEFT ? FlxObject.LEFT : FlxObject.RIGHT;
			owner.velocity.x = FlxG.keys.pressed.LEFT ? -100 : 100;
			
		}
		else
		{
			
			owner.velocity.x *= 0.9;
		}
		
		
	}	
}