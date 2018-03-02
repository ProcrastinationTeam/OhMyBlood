package source.player.states;

import flixel.FlxG;
import flixel.addons.util.FlxFSM;
import flixel.util.FlxColor;
import player.Player;

using flixel.util.FlxSpriteUtil;

class Climb extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{ 
		trace("STATE : CLIMB");
		owner.is_climbing = true;
		
		if (!owner.has_dashed)
		{
			owner.animation.play("idleClimb");
		}
		else
		{
			owner.animation.play("idleBlueClimb");
		}
		
		owner.acceleration.x = 0;
		owner.acceleration.y = 0;
		owner.velocity.y =  0;
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		if (FlxG.keys.justReleased.C)
		{
			
		}
		
		
		if(owner.sideHighRay)
		{
			owner.acceleration.y = 0;
			owner.velocity.y = 0.0;
			
			if (FlxG.keys.pressed.DOWN)
			{
				owner.velocity.y = 25;
			}
		}
		else
		{
			if (FlxG.keys.pressed.UP)
			{
				owner.velocity.y = -25;
			}
			else if (FlxG.keys.pressed.DOWN)
			{
				
				owner.velocity.y = 25;
			}
			else
			{
				owner.acceleration.y = 0;
				owner.velocity.y = 0.0;
			}
		}
		
		if (!owner.has_dashed)
		{
			if (owner.velocity.y < 0)
			{
				owner.animation.play("climb");
			}
			else
			{
				owner.animation.play("idleClimb");
			}
		}
		else
		{
			if (owner.velocity.y < 0)
			{
				owner.animation.play("blueClimb");
			}
			else
			{
				owner.animation.play("idleBlueClimb");
			}
		}
		
		

		
	}
	
	override public function exit(owner:Player):Void
	{
		owner.is_climbing = false;
		owner.acceleration.y = owner.GRAVITY;
		owner.canvas.fill(FlxColor.TRANSPARENT);
		owner.canvas2.fill(FlxColor.TRANSPARENT);
		
	}
	
	
}