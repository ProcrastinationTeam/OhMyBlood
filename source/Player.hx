package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.addons.util.FlxFSM;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ElRyoGrande
 */
class Player extends FlxSprite 
{
	//FSM
	public var fsm:FlxFSM<Player>;
	
	public static inline var DashVelocity = 200;
	
	public var GRAVITY:Float = 500;
	public var _map:FlxTilemap;
	
	public var has_jumped	: Bool = false;
	public var has_dashed	: Bool = false;
	public var dashEnd		: Bool = true;
	public var is_sliding 	: Bool = false;
	public var is_climbing 	: Bool = false;
	public var is_bathing 	: Bool = false;
	
	
	var jumping 		: Bool = false;
	var doubleJumped 	: Bool = false;
	
	private var _maxVel: Int = 200;

	
	//ENEMY RECOGNITION & INTERACTION //A REMOVE
	//public var _enemyList:FlxTypedGroup<Enemy>;
	
	
	//UI AND TEXT
	
	
	///TILE DETECTION
	public var currentLeftTile: Int;
	public var currentRightTile: Int;
	
	//RAYCAST
	public var sideHighRay:Bool;
	public var sideLowRay:Bool;
	
	public var downLeftRay:Bool;
	public var downRightRay:Bool;
	
	public var upLeftRay:Bool;
	public var upRightRay:Bool;
	
	public var downLeftRayImpact : FlxPoint;
	public var downRightRayImpact : FlxPoint;

	public var upLeftRayImpact : FlxPoint;
	public var upRightRayImpact : FlxPoint;
	
	//FACE UP
	private var startUpRightRayPoint : FlxPoint;
	private var endUpRightRayPoint : FlxPoint;
	private var startUpLeftRayPoint : FlxPoint;
	private var endUpLeftRayPoint : FlxPoint;
	
	//FACE DOWN 
	private var startDownRightRayPoint : FlxPoint;
	private var endDownRightRayPoint : FlxPoint;
	private var startDownLeftRayPoint : FlxPoint;
	private var endDownLeftRayPoint : FlxPoint;
	
	//FACE RIGHT
	private var startRightRayPointHigh : FlxPoint; 
	private var endRightRayPointHigh : FlxPoint;    
	private var startRightRayPointLow : FlxPoint; 
	private var endRightRayPointLow : FlxPoint; 
	
	//FACE LEFT
	private var startLeftRayPointHigh : FlxPoint; 
	private var endLeftRayPointHigh : FlxPoint;    
	private var startLeftRayPointLow : FlxPoint; 
	private var endLeftRayPointLow : FlxPoint; 
	
	//INPUT 
	public var lastButtonPressed : FlxKey;
	public var lastButtonDebug : FlxText;
	
	
	//DEBUG UI
	public var canvas:FlxSprite;
	public var canvas2:FlxSprite;
	public var canvas3:FlxSprite;
	public var canvas4:FlxSprite;
	public var canvas5:FlxSprite;
	public var canvas6:FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap) 
	{
		super(X, Y);
		_map = map;
		
		
		//RAYCAST USEFULL
		canvas = new FlxSprite();
		canvas2 = new FlxSprite();
		canvas3 = new FlxSprite();
		canvas4 = new FlxSprite();
		canvas5 = new FlxSprite();
		canvas6 = new FlxSprite();
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		canvas2.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		canvas3.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		canvas4.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		canvas5.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		canvas6.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		
		//RAYCAST INIT
		this.sideHighRay = true;
		this.sideLowRay = true;
		this.downLeftRay = true;
		this.downRightRay = true;
		this.upLeftRay = true;
		this.upRightRay = true;
		this.downLeftRayImpact = new FlxPoint(0, 0);
		this.downRightRayImpact = new FlxPoint(0, 0);
		this.upLeftRayImpact = new FlxPoint(0, 0);
		this.upRightRayImpact = new FlxPoint(0, 0);
		
		
		this.loadGraphic("assets/images/hero.png", true, 16, 16, false);
		
		this.setFacingFlip(FlxObject.RIGHT, false, false);
		this.setFacingFlip(FlxObject.LEFT, true, false);
		this.facing = FlxObject.RIGHT;
		
		this.animation.add("idle", [0, 1], 3);
		this.animation.add("walk", [0, 2, 3, 2], 12);
		this.animation.add("jump", [0, 2, 3, 4] , 30, false); 
		this.animation.add("blueJump", [8, 7], false);
		this.animation.add("fall", [5]);
		this.animation.add("blueFall", [6]);
		this.animation.add("dash", [9, 10, 11], false);
		this.animation.add("idleClimb", [12]);
		this.animation.add("idleBlueClimb", [14]);
		this.animation.add("climb", [12,13],2,true);
		this.animation.add("blueClimb", [14, 15], 2, true);
		this.animation.add("slide", [12],  true);
		this.animation.add("blueSlide", [14], true);
		
		this.animation.add("bloodBathIn",[16,17,18,19],4,false);
		this.animation.add("bloodBathOut",[19,18,17,16],4,false);
		
		//PHYSIC INIT
		this.setSize(8, 16);
		this.offset.set(4, 0);
		acceleration.y = GRAVITY;
		this.maxVelocity.set(150, GRAVITY);
		

		//FSM INIT
		fsm = new FlxFSM<Player>(this);
		fsm.transitions
		
			//.add(Idle,Walk,Conditions.walk)
		
			.add(Walk, Jump, Conditions.jump)
			.add(Walk, Dash, Conditions.dash)
			.add(Walk, Fall, Conditions.fall)
			.add(Walk, Climb, Conditions.climb)
			
			.add(Jump, Walk, Conditions.grounded)
			.add(Jump, Fall, Conditions.fall)
			.add(Jump, Dash, Conditions.dash)
			.add(Jump, Climb, Conditions.climb)
			.add(Jump, SlideWall, Conditions.slideWall)
			
			.add(Fall, Walk, Conditions.grounded)
			.add(Fall, Dash, Conditions.dash)
			.add(Fall, Climb, Conditions.climb)
			.add(Fall, SlideWall, Conditions.slideWall) 
			.add(Fall, Jump, Conditions.jump)
			
			.add(Dash, Walk, Conditions.grounded)
			.add(Dash, Fall, Conditions.fall)
			.add(Dash, Climb, Conditions.climb)
			.add(Dash, SlideWall, Conditions.slideWall)
			
			.add(Climb, Walk, Conditions.grounded)
			.add(Climb, Fall, Conditions.releaseClimb)
			.add(Climb, Fall, Conditions.fallFromClimb)
			.add(Climb, Dash, Conditions.dash)
			.add(Climb, Jump, Conditions.jump)
			.add(Climb, SlideWall, Conditions.slideWall)
			
			.add(SlideWall, Walk, Conditions.grounded)
			.add(SlideWall, Dash, Conditions.dash)
			.add(SlideWall, Fall, Conditions.fallFromClimb)
			.add(SlideWall, Jump, Conditions.jump)
			.add(SlideWall, Climb, Conditions.climb)
			
			
			.add(Walk,BloodBath,Conditions.bbIn)
			.add(BloodBath, BloodBathFinish, Conditions.bbOut)
			.add(BloodBathFinish, Walk, Conditions.animationFinished)
			
			.start(Walk);
				
	}
	
	override public function update(elapsed:Float):Void
	{
		//LE RAYCAST NE SEMBLE PAS BIEN FONCTIONNE (IL FAUT METTRE UNE VALEURE AU DERNIER PARAMETRE POUR PLUS DE PRECISION ! )
		//DEBUG RAYCAST
		this.canvas.fill(FlxColor.TRANSPARENT);
		this.canvas2.fill(FlxColor.TRANSPARENT);
		this.canvas3.fill(FlxColor.TRANSPARENT);
		this.canvas4.fill(FlxColor.TRANSPARENT);
		this.canvas5.fill(FlxColor.TRANSPARENT);
		this.canvas6.fill(FlxColor.TRANSPARENT);
		
		var lineStyle:LineStyle = { color: FlxColor.RED, thickness: 1 };
		var lineStyle2:LineStyle = { color: FlxColor.GREEN, thickness: 1 };
		var lineStyle3:LineStyle = { color: FlxColor.ORANGE, thickness: 1 };
	
		
		//DOWN RAY
		startDownRightRayPoint = new FlxPoint(this.x + this.width - 1, this.y + this.height );
		endDownRightRayPoint = new FlxPoint(this.x + this.width - 1, this.y + this.height + 2 );
		startDownLeftRayPoint = new FlxPoint(this.x + 1, this.y  + this.height );
		endDownLeftRayPoint = new FlxPoint(this.x + 1, this.y + this.height + 2 );
		
		this.downRightRay = this._map.ray(startDownRightRayPoint, endDownRightRayPoint,downRightRayImpact, 10);
		this.downLeftRay = this._map.ray(startDownLeftRayPoint, endDownLeftRayPoint,downLeftRayImpact, 10);
		
		this.canvas3.drawLine( startDownRightRayPoint.x,  startDownRightRayPoint.y, endDownRightRayPoint.x, endDownRightRayPoint.y, lineStyle3);
		this.canvas4.drawLine(startDownLeftRayPoint.x,startDownLeftRayPoint.y, endDownLeftRayPoint.x, endDownLeftRayPoint.y, lineStyle3);
		
		//On recupere la tile pour voir si on peut lancer le bloodbath
		this.currentLeftTile = this._map.getTileByIndex(this._map.getTileIndexByCoords(downLeftRayImpact));
		this.currentRightTile = this._map.getTileByIndex(this._map.getTileIndexByCoords(downRightRayImpact));
		
		//UP RAY
		startUpRightRayPoint = new FlxPoint(this.x + this.width - 1, this.y);
		endUpRightRayPoint = new FlxPoint(this.x + this.width - 1, this.y - 2 );
		startUpLeftRayPoint = new FlxPoint(this.x + 1, this.y );
		endUpLeftRayPoint = new FlxPoint(this.x + 1, this.y - 2 );
		
		this.upRightRay = this._map.ray(startUpRightRayPoint, endUpRightRayPoint,upRightRayImpact, 10);
		this.upLeftRay = this._map.ray(startUpLeftRayPoint, endUpLeftRayPoint, upLeftRayImpact, 10);
		
		this.canvas5.drawLine( startUpRightRayPoint.x,  startUpRightRayPoint.y, endUpRightRayPoint.x, endUpRightRayPoint.y, lineStyle3);
		this.canvas6.drawLine(startUpLeftRayPoint.x,startUpLeftRayPoint.y, endUpLeftRayPoint.x, endUpLeftRayPoint.y, lineStyle3);
		
		
		if (this.facing == FlxObject.RIGHT)
		{
			var impactHigh = new FlxPoint(0,0);
			var impactLow = new FlxPoint(0, 0);
			
			startRightRayPointHigh = new FlxPoint(this.x + this.width, this.y + 8);
			endRightRayPointHigh = new FlxPoint(this.x + this.width + 4 , this.y + 8);	
			startRightRayPointLow = new FlxPoint(this.x + this.width, this.y + 12);
			endRightRayPointLow = new FlxPoint(this.x + this.width + 4 , this.y + 12);
			
			this.sideHighRay = this._map.ray(startRightRayPointHigh, endRightRayPointHigh, impactHigh, 10);
			this.sideLowRay = this._map.ray(startRightRayPointLow, endRightRayPointLow, impactLow, 10);
			
			this.canvas.drawLine(startRightRayPointHigh.x, startRightRayPointHigh.y, endRightRayPointHigh.x, endRightRayPointHigh.y, lineStyle);
			this.canvas2.drawLine(startRightRayPointLow.x, startRightRayPointLow.y, endRightRayPointLow.x, endRightRayPointLow.y, lineStyle2);
			
		}
		else
		{	
			var impactHigh = new FlxPoint(0,0);
			var impactLow = new FlxPoint(0, 0);
			
			startLeftRayPointHigh = new FlxPoint(this.x , this.y + 8);
			endLeftRayPointHigh = new FlxPoint(this.x - 4 , this.y + 8);
			startLeftRayPointLow = new FlxPoint(this.x , this.y + 12);
			endLeftRayPointLow = new FlxPoint(this.x - 4 , this.y + 12);
			
			this.sideHighRay = this._map.ray(startLeftRayPointHigh, endLeftRayPointHigh,impactHigh,10);
			this.sideLowRay = this._map.ray(startLeftRayPointLow,endLeftRayPointLow,impactLow,10);
						
			this.canvas.drawLine(startLeftRayPointHigh.x, startLeftRayPointHigh.y, endLeftRayPointHigh.x, endLeftRayPointHigh.y, lineStyle);
			this.canvas2.drawLine(startLeftRayPointLow.x, startLeftRayPointLow.y, endLeftRayPointLow.x, endLeftRayPointLow.y , lineStyle2);
			
		}
		

		
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
	
	public static function grounded(Owner: Player):Bool
	{	
		//return (Owner.isTouching(FlxObject.DOWN) && !Owner.is_climbing);
		return ((!Owner.downRightRay || !Owner.downLeftRay) && !Owner.is_climbing && Owner.dashEnd);
	}
	
	public static function bbIn(Owner:Player):Bool
	{
		return (FlxG.keys.justPressed.CONTROL && !Owner.is_bathing && (Owner.currentLeftTile == 2 || Owner.currentRightTile == 2) && (!Owner.downRightRay || !Owner.downLeftRay));  
	}
	
	public static function bbOut(Owner:Player):Bool
	{
		return (FlxG.keys.justPressed.CONTROL && Owner.is_bathing && (Owner.upRightRay && Owner.upLeftRay));  
	}
	
	public static function groundedFromClimb(Owner: Player):Bool
	{	
		//return (Owner.isTouching(FlxObject.DOWN) && (FlxG.keys.justReleased.C));
		return ((!Owner.downRightRay || !Owner.downLeftRay) && (FlxG.keys.justReleased.C));
	}
	
	public static function jump(Owner: Player):Bool
	{
		return (FlxG.keys.justPressed.SPACE && (!Owner.downRightRay || !Owner.downLeftRay || !Owner.sideHighRay || !Owner.sideLowRay));
		//return (FlxG.keys.justPressed.SPACE);
	}
	
	public static function fall(Owner: Player):Bool
	{
		return (!Owner.is_sliding &&  Owner.velocity.y > 0);
	}
	
	public static function fallFromClimb(Owner: Player):Bool
	{
		return (Owner.sideHighRay && Owner.sideLowRay);
	}
	
	public static function dash(Owner: Player):Bool
	{
		return (FlxG.keys.justPressed.D && !Owner.has_dashed);
	}
	
	public static function climb(Owner:Player):Bool
	{
		return( FlxG.keys.pressed.C && !Owner.has_jumped  && !Owner.sideHighRay); 
	}
	
	public static function releaseClimb(Owner:Player):Bool
	{
		return(FlxG.keys.justReleased.C); 
	}
	
	public static function slideWall(Owner:Player):Bool
	{
		return ((FlxG.keys.pressed.RIGHT && Owner.isTouching(FlxObject.RIGHT)) || (FlxG.keys.pressed.LEFT && Owner.isTouching(FlxObject.LEFT))) && (Owner.downRightRay || Owner.downLeftRay) && !FlxG.keys.pressed.C && Owner.velocity.y >0;
	}
	
	public static function animationFinished(Owner:Player):Bool
	{
		return Owner.animation.finished;
	}
}

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

class BloodBath extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : BLOODBATH");
		owner.animation.play("bloodBathIn");
		owner.is_bathing = true;
		owner.acceleration.y = 0;
		owner.acceleration.x = 0;
		owner.allowCollisions = FlxObject.NONE;
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

class BloodBathFinish extends FlxFSMState<Player>
{
	override public function enter(owner: Player, fsm:FlxFSM<Player>):Void
	{
		trace("STATE : BLOODBATH FINISH");
		owner.animation.play("bloodBathOut");
		owner.velocity.x = 0;
	}
}

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
			owner.velocity.x = FlxG.keys.pressed.LEFT ? -75 : 75;
			
		}
		else
		{
			
			owner.velocity.x *= 0.9;
		}
		
		
	}	
}

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