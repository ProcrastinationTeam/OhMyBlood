package source.player.states;

import flixel.addons.util.FlxFSM;
import player.Player;

class BloodBathFinish extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : BLOODBATH FINISH");
		owner.animation.play("bloodBathOut");
		owner.velocity.x = 0;
		owner.visibilityIcon.visible = true;
	}
}