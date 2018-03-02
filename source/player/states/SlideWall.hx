package source.player.states;

import flixel.addons.util.FlxFSM;
import player.Player;

class SlideWall extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{ 
		trace("STATE : SLIDEWALL");
		owner.is_sliding = true;
		if (owner.has_dashed)
		{
			owner.animation.play("blueSlide");
		}
		else
		{
			owner.animation.play("slide");
		}
		
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		
		
		if (owner.velocity.y > 0)
		{
			//owner.acceleration.y = owner.GRAVITY * 0.125;
			owner.acceleration.y = owner.GRAVITY * 0.05;
		}
		
		
		//SI ON PRESSE LA TOUCHE OPPOSE ON PEUT LACHER LE MUR
		
	}
	
	override public function exit(owner:Player):Void
	{
		owner.acceleration.y = owner.GRAVITY;
		owner.velocity.x = 0;
		owner.is_sliding = false;
	}
	
}