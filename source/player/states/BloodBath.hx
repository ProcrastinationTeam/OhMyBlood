package source.player.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

class BloodBath extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : BLOODBATH");
		owner.animation.play("bloodBathIn");
		owner.is_bathing = true;
		owner.acceleration.y = 0;
		owner.acceleration.x = 0;
		owner.visibilityIcon.visible = false;
		//owner.allowCollisions = FlxObject.NONE;
		owner.setSize(8, 4);
		owner.offset.set(4, 12);
		owner.setPosition(owner.getPosition().x, owner.getPosition().y + 12);
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		owner.acceleration.x = 0;
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		if (owner.animation.finished)
		{
			
			if(owner.currentLeftTile != 2 || owner.downLeftRay)
			{
				
				if (FlxG.keys.pressed.RIGHT)
				{
					owner.velocity.x = 100;
				}
			}
			
			if(owner.currentRightTile != 2 || owner.downRightRay)
			{
				
				if (FlxG.keys.pressed.LEFT)
				{
					owner.velocity.x = -100;
				}
			}
			
			if(owner.currentRightTile == 2 && owner.currentLeftTile == 2 && (!owner.downRightRay && !owner.downLeftRay) )
			{			
				if (FlxG.keys.pressed.RIGHT)
				{
					owner.velocity.x = 100;
				}
				else if (FlxG.keys.pressed.LEFT)
				{
					owner.velocity.x = -100;
				}
			}

			
		}
		
	}
	
	override public function exit(owner: Player):Void
	{
		owner.is_bathing = false;
		owner.velocity.x = 0;
		owner.acceleration.x = 0;
		owner.acceleration.y = owner.GRAVITY;
		owner.allowCollisions = FlxObject.ANY;
		owner.setSize(8, 16);
		owner.offset.set(4, 0);
		owner.setPosition(owner.getPosition().x, owner.getPosition().y - 12);
	}

}