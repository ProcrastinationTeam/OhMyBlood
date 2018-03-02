package source.player.states;

import flixel.addons.util.FlxFSM;
import player.Player;

//A voir si on l'utilise
class Idle extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : IDLE");
		
		owner.animation.play("idle");
		owner.has_dashed = false;
		owner.has_jumped = false;
		
		//A TWEAKER
		owner.acceleration.x = 10;
		//owner.velocity.x /= 2;
	}
}