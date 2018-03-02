package source.player.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

class Walk extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : WALK");
		
		owner.animation.play("idle");
		owner.has_dashed = false;
		owner.has_jumped = false;
		
		//A TWEAKER
		owner.acceleration.x = 10;
		//owner.velocity.x /= 2;
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		//AMELIORER POUR FAIRE EN SORTE QUE LA GLISSADE LORS D'UNE MARCHE ARRIERE NE SOIT PAS TROP CHIANTE
		
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			var facing = owner.facing;
			owner.facing = FlxG.keys.pressed.LEFT ? FlxObject.LEFT : FlxObject.RIGHT;
			owner.animation.play("walk");
		
			if (owner.facing != facing)
			{
				owner.velocity.x /= 8;
			}
			else
			{
				owner.acceleration.x = FlxG.keys.pressed.LEFT ? -100 : 100;
			}
			
			if ((owner.velocity.x) >= 100)
			{
				owner.velocity.x = 100;
				
			}
			else if ((owner.velocity.x) <= -100)
			{
				owner.velocity.x = -100;
				//owner.acceleration.x = 0;
			}
			//if (FlxMath.absInt(Std.int(owner.velocity.x)) > 200)
			//{
				//owner.velocity.x = 200 * (owner.velocity.x /(FlxMath.absInt(Std.int(owner.velocity.x))));
			//}	
		}
		else
		{
			owner.animation.play("idle");
			//owner.velocity.x *= 0.9;
			owner.velocity.x = 0.0;
		}
	}	
}