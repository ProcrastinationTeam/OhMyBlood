package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.FlxKeyManager;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.replay.FlxReplay;

/**
 * ...
 * @author ElRyoGrande
 */
class Hero extends FlxSprite 
{
	
	public var fsm:FlxFSM<Hero>;
	public var GRAVITY:Float = 500;

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		this.loadGraphic("assets/images/hero.png", true, 16, 16, false);	
		this.setFacingFlip(FlxObject.RIGHT, false, false);
		this.setFacingFlip(FlxObject.LEFT, true, false);
		this.facing = FlxObject.RIGHT;
		this.setSize(8, 16);
		this.offset.set(4, 0);
		acceleration.y = GRAVITY;
		this.maxVelocity.set(150, GRAVITY);
		
		fsm = new FlxFSM<Hero>(this);
		fsm.transitions
		.add(Walk, Jump, Conditions.jump)
		.add(Jump, Walk, Conditions.grounded)
		.start(Walk);
	}
	
	override public function update(elapsed:Float):Void
	{
		//trace(isTouching(FlxObject.DOWN));
		fsm.update(elapsed);
		super.update(elapsed);
	
	}
	
	override public function destroy():Void 
	{
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
}

class Conditions
{
	
	public static function grounded(Owner: Hero):Bool
	{	
		return (Owner.isTouching(FlxObject.DOWN));
	}
	
	public static function jump(Owner: Hero):Bool
	{
		return (FlxG.keys.checkStatus(FlxKey.SPACE,FlxInputState.JUST_PRESSED));
		//return (
	}
	
	
}


class Walk extends FlxFSMState<Hero>
{
	override public function enter(owner: Hero, fsm:FlxFSM<Hero>):Void
	{
		trace("STATE : WALK");
		
	}
	
	override public function update(elapsed:Float, owner:Hero, fsm:FlxFSM<Hero>):Void 
	{
		if (FlxG.keys.pressed.RIGHT)
		{
			owner.velocity.x = 50;
		}
		
		if (FlxG.keys.pressed.LEFT)
		{
			owner.velocity.x = -50;
		}
	}	
}


class Jump extends FlxFSMState<Hero>
{
	private var _ticks:Float;
	
	override public function enter(owner: Hero, fsm:FlxFSM<Hero>):Void
	{
		trace("STATE : JUMP");
		owner.velocity.y = -150;
		
		
		
		
	}
	
	
	override public function update(elapsed:Float, owner:Hero, fsm:FlxFSM<Hero>):Void 
	{
		
		if (FlxG.keys.pressed.RIGHT)
		{
			owner.velocity.x = 50;
		}
		
		if (FlxG.keys.pressed.LEFT)
		{
			owner.velocity.x = -50;
		}
		
	}	
	
}