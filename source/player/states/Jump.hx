package source.player.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

//IDEE : RAYCAST POUR LE REBOND CONTRE LE MUR
class Jump extends FlxFSMState<Player>
{
	private var _ticks:Float;
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : JUMP");
		_ticks = 0;
		owner.has_jumped = true;
		owner.animation.play("jump");
	
		
		if ((!owner.sideHighRay || !owner.sideLowRay) && (owner.downLeftRay && owner.downRightRay))
		{
			//CLIMB JUMP
			if (FlxG.keys.pressed.C)
			{
				trace("U WAS CLIMBING");
				if (FlxG.keys.pressed.LEFT)
				{
						trace("CLIMB JUMP FOR LEFT");
						owner.facing = FlxObject.LEFT;
						owner.velocity.x = -100;
						owner.velocity.y = -150;
				}
				else if (FlxG.keys.pressed.RIGHT)
				{
						trace("CLIMB JUMP FOR RIGHT");
						owner.facing = FlxObject.RIGHT;
						owner.velocity.x = 100;
						owner.velocity.y = -150;
				}
				else
				{
						owner.velocity.y = -150;
				}
			}
			//WALL JUMP
			else
			{
				if (owner.facing == FlxObject.LEFT)
				{
					trace("WALL JUMP TO RIGHT");
						owner.velocity.x = 100;
						owner.velocity.y = -150;
				}
				else
				{
						trace("WALL JUMP TO LEFT");
						owner.velocity.x = -100;
						owner.velocity.y = -150;
				}
				
			}
		}
		//SIMPLE JUMP
		else
		{
			trace("SAUT NORMAL");
			owner.velocity.y = -150;
		}
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		_ticks++;
		
		if (FlxG.keys.pressed.LEFT)
		{
			owner.facing = FlxObject.LEFT  ;
		}
		else if(FlxG.keys.pressed.RIGHT)
		{
			owner.facing = FlxObject.RIGHT;
		}
		
		
		if (_ticks > 10)
		{
			owner.has_jumped = false;
		}
	}	
	
	override public function exit(owner: Player)
	{
		owner.has_jumped = false;
	}
}