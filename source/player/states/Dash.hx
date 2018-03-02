package source.player.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.util.FlxFSM;
import player.Player;

class Dash extends FlxFSMState<Player>
{
	private var _ticks :Float;
	
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{ 
		
		trace("STATE : DASH");
		owner.acceleration.y = 0;
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		owner.animation.play("dash");
		owner.has_dashed = true;
		
		owner.dashEnd = false;
		_ticks = 0;
		//owner.velocity.y = -200;
		//owner.velocity.x = 200;
	}
	
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void 
	{
		_ticks++;
	
		
		if (_ticks == 1 )
		{
			if (FlxG.keys.pressed.UP)
			{
				if (FlxG.keys.pressed.LEFT)
				{
					trace("HAUT GAUCHE");
					owner.velocity.y = -Player.DashVelocity;
					owner.velocity.x =  -Player.DashVelocity;
					
				}
				else if (FlxG.keys.pressed.RIGHT)
				{
					trace("HAUT DROIT");
					owner.velocity.y = -Player.DashVelocity;
					owner.velocity.x = Player.DashVelocity;
				}
				else
				{
					trace("HAUT");
					owner.velocity.y = -Player.DashVelocity;
				}
			}
			else if (FlxG.keys.pressed.DOWN)
			{
				if (FlxG.keys.pressed.LEFT)
				{
					trace("BAS GAUCHE");
					owner.velocity.y =  Player.DashVelocity;
					owner.velocity.x = -Player.DashVelocity;
				}
				else if (FlxG.keys.pressed.RIGHT)
				{
					trace("BAS DROIT");
					owner.velocity.y =  Player.DashVelocity;
					owner.velocity.x =  Player.DashVelocity;
				}
				else
				{
					trace("BAS");
					owner.velocity.y = Player.DashVelocity;
				}
			}
			else if (FlxG.keys.pressed.RIGHT)
			{
				trace("GAUCHE");
				owner.velocity.x =  Player.DashVelocity;
			}
			else if (FlxG.keys.pressed.LEFT)
			{
				trace("DROIT");
				owner.velocity.x = -Player.DashVelocity;
			}
			else
			{
				if (owner.facing == FlxObject.LEFT)
				{
					trace("GAUCHE");
					owner.velocity.x =  -Player.DashVelocity;
				}
				else
				{	
					trace("DROIT");
					owner.velocity.x = Player.DashVelocity;
				}
			}
		}
		else if(_ticks > 10 || !owner.sideHighRay)
		{
			//owner.velocity.x = owner.velocity.x;
			//owner.velocity.y = owner.velocity.y;
			owner.acceleration.x = 0;
			owner.acceleration.y = owner.GRAVITY;
			owner.dashEnd = true;
			
		}
		else
		{
			//owner.dashEnd = true;
			
		}
	}	
	
	override public function exit(owner:Player):Void
	{
		
		owner.dashEnd = true;
		owner.acceleration.y = owner.GRAVITY;
	}
}