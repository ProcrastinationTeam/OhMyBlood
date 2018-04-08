package npcs.npcs;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import player.Player;

/**
 * ...
 * @author ElRyoGrande
 */
class EnemyFearable extends Enemy 
{
	//FSM
	public var fsm:FlxFSM<EnemyFearable>;

	
	//USEFULL
	public var seePlayer:Bool = false;
	public var _health:Int = 100;
	
	// TEST
	public var _suspicion:Int = 0;
	public var _suspicious:Bool = false;
	public var _playerRepered:Bool = false;
	public var tempoAvirer:Int = 0;
	public var _isFearable: Bool = true;
	public var _playerDistanceFromEnemy:Float;
	public var _initialPos:FlxPoint;

	
	//IA var
	public var _nullPosition : FlxPoint;
	public var _lastPlayerPositionKnown:FlxPoint;
	public var _distanceToPlayer:Int;

		public static  var _vectorR:FlxVector = new FlxVector(1, 0);
		public static  var _vectorL:FlxVector = new FlxVector( -1, 0);
		
		
	
	public var checkWallRay:Bool;
	
	

	
	//DEBUG
	public var _debugText:FlxText;
	public var _debugStateText:FlxText;
	
	
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap, player:Player) 
	{
		//BASIC INIT
		super(X, Y, map, player);
		_initialPos = new FlxPoint(X, Y);
		
		//GRAPHICS INIT
		this.loadGraphic("assets/images/enemyFearable.png", true, 16, 16, false);
		
		this.setFacingFlip(FlxObject.RIGHT, false, false);
		this.setFacingFlip(FlxObject.LEFT, true, false);
		this.facing = FlxObject.RIGHT;
		
		this.animation.add("idle", [0]);
		this.animation.add("walk", [0, 1], 6, true);
		this.animation.add("dieStart", [0,2,3,4,4,4,4,4], 6,false);
		this.animation.add("dieEnd", [5, 5, 5, 6], 6, false);
		this.animation.add("fear", [7, 8], 6, true);
		this.animation.play("idle");
		
		
		//PHYSICS INIT
		this.setSize(8, 16);
		this.offset.set(4, 0);
		acceleration.y = 500;
		this.maxVelocity.set(150, 500);
		
		//FSM INIT
		fsm = new FlxFSM<EnemyFearable>(this);
		fsm.transitions
		.add(EnemyFearableIdle, EnemyFearableFear, EnemyFearableConditions.fear)
		.add(EnemyFearableIdle, EnemyFearableDead, EnemyFearableConditions.dead)
		.add(EnemyFearableFear, EnemyFearableIdle, EnemyFearableConditions.calm_down)
		.add(EnemyFearableFear, EnemyFearableDead, EnemyFearableConditions.dead)
		.start(EnemyFearableIdle);
		
		//AI INIT
		_lastPlayerPositionKnown = new FlxPoint();
		_nullPosition = new FlxPoint();
		
		//RAYCAST SECTION 
		checkWallRay = true;
		
		
		
		
		
		//DEBUG TEXT
		_debugText = new FlxText(this.x, this.y - 20, 0, "SEE : ", 8);
		_debugStateText = new FlxText(this.x, this.y - 30, 0, "", 8);
		
		
	}
	
	override public function update(elapsed:Float):Void
	{
		
		_playerDistanceFromEnemy = this.x - _player.x; 
		
		//trace("LAST POS KNOWN : " + this._lastPlayerPositionKnown);
		if (this.facing == FlxObject.RIGHT)
		{
			checkWallRay = this._map.ray(new FlxPoint(this.x,this.y+10), new FlxPoint(this.x + 10, this.y+10), 10);
		}
		else
		{
			checkWallRay = this._map.ray(new FlxPoint(this.x,this.y+10), new FlxPoint(this.x - 10, this.y+10), 10); 
		}
		
		
		checkEnemyVision();
		_debugText.setPosition(this.x , this.y - 20);
		_debugText.text = "SEE : " + _suspicion;
		
		_debugStateText.setPosition(this.x , this.y - 30);
		
		fsm.update(elapsed);
		super.update(elapsed);
	}
	
	override public function destroy():Void 
	{
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
	
	
	override public function kill():Void
	{
		//fsm = null;
		_health = 0;
		
		//alive = false;
		//exists = false;
	}
	
	private function checkEnemyVision()
	{
		var currentVector:FlxVector;
		
		//Prendre en compte le facing
		if (facing == FlxObject.LEFT)
		{
			currentVector = _vectorL;
		}
		else
		{
			currentVector = _vectorR;
		}
		
		//si le dotproduct est négatif alors l'enemy regarde dans le sens ou se trouve le joueur et donc le vois
		//sinon c'est l'inverse
		var dotProd = currentVector.dotProduct(new FlxVector(FlxMath.signOf(_playerDistanceFromEnemy), 0));
		
		//calcul de distance nécessaire
		_distanceToPlayer = FlxMath.distanceBetween(this, _player);
	
		
		if (_distanceToPlayer <= Tweaking.ennemyVisionDistance && dotProd < 0 &&  _map.ray(new FlxPoint(this.x,this.y), _player.getMidpoint()) && !_player.is_bathing )
		{
			seePlayer = true;
			
			if (!this._isFearable)
			{
				_lastPlayerPositionKnown = _player.getPosition();
			}
			
			if (_suspicion < 100)
			{
				_suspicion++;
			}
			else
			{
				_suspicion = 100;
			}
			
		}
		else
		{
			seePlayer = false;
			if (_playerRepered || _isFearable)
			{
				if (tempoAvirer == 5)
				{
					if (_suspicion > 0)
					{
						_suspicion--;
					}
					else
					{
						_suspicion = 0;
					}
					
					tempoAvirer = 0;
				}
				tempoAvirer++;
				
			}
			else
			{
				if (_suspicion > 0)
				{
					_suspicion--;
				}
				else
				{
					_suspicion = 0;
				}
			}
		}
	}
	
}


class EnemyFearableConditions
{
	
	public static function idle(Owner:EnemyFearable)
	{
		return(!Owner.seePlayer);
	}

	public static function see(Owner:EnemyFearable)
	{
		return(Owner.seePlayer && !Owner._isFearable);
	}
	
	public static function dead(Owner:EnemyFearable)
	{
		return(Owner._health <= 0);
	}
	
	public static function fear(Owner:EnemyFearable)
	{
		return(Owner._suspicion < 20 && Owner._isFearable && Owner.seePlayer);
	}
	
	public static function calm_down(Owner:EnemyFearable)
	{
		return(Owner._suspicion <= 5 && Owner._isFearable);
	}
	
}

class EnemyFearableIdle extends FlxFSMState<EnemyFearable>
{
	override public function enter(owner:EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void 
	{
		trace("ENEMY ENTER IDLE MODE");
		owner.animation.play("idle");
		owner._debugStateText.text = "IDLE";
		owner._suspicious = false;
	}
	
	
	override public function update(elapsed:Float, owner:EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void 
	{
		
		
	//	if (!owner._initialPos.equals(owner.getPosition()))
		//if (owner._initialPos.x != owner.getPosition().x )
		//{
			//owner.animation.play("walk");
			//var dir = owner.getPosition().x - owner._initialPos.x;
			//if (dir > 0)
			//{
				//owner.facing = FlxObject.LEFT;
				//owner.velocity.x = -20;
			//}
			//else
			//{
				//owner.facing = FlxObject.RIGHT;
				//owner.velocity.x = 20;
			//}
			//
		//}
		//else
		//{
			//owner.velocity.x = 0;
		//}
	}
	
	override public function exit(owner:EnemyFearable):Void 
	{
		
	}
	
}


class EnemyFearableFear extends FlxFSMState<EnemyFearable>
{
	
	override public function enter(owner:EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void 
	{
		trace("ENEMY ENTER FEAR MODE");
		owner._suspicion = 100;
		owner._debugStateText.text = "FEAR";
		owner.animation.play("fear");
	}
	
	
	override public function update(elapsed:Float, owner:EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void 
	{
		if (owner._playerDistanceFromEnemy > 0)
			{
				owner.velocity.x = 30;
				owner.facing = FlxObject.RIGHT;
			}
			else
			{
				owner.velocity.x = -30;
				owner.facing = FlxObject.LEFT;
			}
	}
	
	override public function exit(owner:EnemyFearable):Void 
	{
		owner.velocity.x = 0;
	}
	
}


class EnemyFearableDead extends FlxFSMState<EnemyFearable>
{
	var count = 0;
	override public function enter(owner: EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void
	{
		trace("I'm DEAD");	
		owner._debugStateText.text = "DEAD";
		owner.animation.play("dieStart");
		owner.allowCollisions = FlxObject.NONE;
		owner.velocity.x  = 0;
		owner.velocity.y  = 0;
		owner.acceleration.x = 0;
		owner.acceleration.y = 0;
		owner._particleEmitter.setPosition(owner.x + owner.width / 2, owner.y + 3 );
		owner._particleEmitter.start(false, 0.01, 150);
	
	}
	
	override public function update(elapsed:Float,owner: EnemyFearable, fsm:FlxFSM<EnemyFearable>):Void
	{
		if (owner.animation.finished && count == 0)
		{
			owner.animation.play("dieEnd");
			count++;
		}

	}
	
	override public function exit(owner: EnemyFearable):Void
	{
		
	}
}