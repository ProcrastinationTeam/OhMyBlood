package player;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import player.states.Ladder;
import source.player.states.*;
import source.player.Conditions;

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
	public var on_ladder 	: Bool = false;
	public var grab_ladder 	: Bool = false;
	
	public var visibility : Int = 0;
	
	var jumping 		: Bool = false;
	var doubleJumped 	: Bool = false;
	
	private var _maxVel: Int = 200;

	//test for biting enemy
	public var biteHitbox : FlxObject;
	
	
	
	
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
	
	public var visibilityIcon : VisibilityIcon;
	
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
		
		visibilityIcon = new VisibilityIcon(camera.width - 50 + camera.scroll.x, 50 + camera.scroll.y);
		
		
		
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
		
		//HITBOX SUPPLEMENTAIRE
		biteHitbox = new FlxObject(this.getMidpoint().x, Y, 8, 10);
		
		

		//FSM INIT
		fsm = new FlxFSM<Player>(this);
		fsm.transitions
		
			//.add(Idle,Walk,Conditions.walk)
		
			.add(Walk, Jump, Conditions.jump)
			.add(Walk, Dash, Conditions.dash)
			.add(Walk, Fall, Conditions.fall)
			.add(Walk, Climb, Conditions.climb)
			.add(Walk, Ladder, Conditions.ladder)
			
			.add(Jump, Walk, Conditions.grounded)
			//peut etre creer un state wall jump
			.add(Jump, Jump, Conditions.jump)
			.add(Jump, Fall, Conditions.fall)
			.add(Jump, Dash, Conditions.dash)
			.add(Jump, Climb, Conditions.climb)
			.add(Jump, SlideWall, Conditions.slideWall)
			.add(Jump, Ladder, Conditions.ladder)
			
			.add(Fall, Walk, Conditions.grounded)
			.add(Fall, Dash, Conditions.dash)
			.add(Fall, Climb, Conditions.climb)
			.add(Fall, SlideWall, Conditions.slideWall) 
			.add(Fall, Jump, Conditions.jump)
			.add(Fall, Ladder, Conditions.ladder)
			
			.add(Ladder, Walk, Conditions.leaveLadder)
			.add(Ladder, Fall, Conditions.leaveLadder)
			.add(Ladder, Jump, Conditions.jump)
			
			
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
		//	.add(SlideWall, Ladder, Conditions.ladder)
			
			.add(Walk,BloodBath,Conditions.bbIn)
			.add(BloodBath, BloodBathFinish, Conditions.bbOut)
			.add(BloodBathFinish, Walk, Conditions.animationFinished)
			
			.start(Walk);
				
	}
	
	override public function update(elapsed:Float):Void
	{
		
		visibilityIcon.getPlayerVisibility(this.visibility);
		
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
		startDownRightRayPoint = new FlxPoint(this.x + this.width -1, this.y + this.height );
		endDownRightRayPoint = new FlxPoint(this.x + this.width -1, this.y + this.height + 2 );
		startDownLeftRayPoint = new FlxPoint(this.x +1, this.y  + this.height );
		endDownLeftRayPoint = new FlxPoint(this.x+1 , this.y + this.height + 2 );
		
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
				
			biteHitbox.setPosition(this.x + this.width, this.y);
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
			
			biteHitbox.setPosition(this.x - this.width, this.y);
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