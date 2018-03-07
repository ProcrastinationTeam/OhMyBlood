package;

import flash.display.IBitmapDrawable;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import player.Player;

/**
 * ...
 * @author ElRyoGrande
 */
class Enemy extends FlxSprite 
{
	//FSM
	public var fsm:FlxFSM<Enemy>;

	//TILEMAP
	public var _map:FlxTilemap;
	
	//USEFULL
	public var _player:Player;
	public var seePlayer:Bool = false;
	public var _health:Int = 100;
	
		//TEST
	public var _suspicion:Int = 0;
	public var _suspicious:Bool = false;
	public var _playerRepered:Bool = false;
	public var tempoAvirer:Int = 0;
	public var _isFearable: Bool = false;
	public var _playerDistanceFromEnemy:Float;
	public var _initialPos:FlxPoint;

	
	//IA var
	public var _nullPosition : FlxPoint;
	public var _lastPlayerPositionKnown:FlxPoint;
	public var _distanceToPlayer:Int;

		public static  var _vectorR:FlxVector = new FlxVector(1, 0);
		public static  var _vectorL:FlxVector = new FlxVector( -1, 0);
		
		
	
	public var checkWallRay:Bool;
	
	
	//PARTICLE SYSTEM
	public var _particleEmitter:FlxEmitter;
	
	//DEBUG
	public var _debugText:FlxText;
	public var _debugStateText:FlxText;
	
	
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap, player:Player) 
	{
		//BASIC INIT
		super(X, Y);
		_map = map;
		_player = player;
		_initialPos = new FlxPoint(X, Y);
		
		//GRAPHICS INIT
		this.loadGraphic("assets/images/enemy.png", true, 16, 16, false);
		
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
		fsm = new FlxFSM<Enemy>(this);
		fsm.transitions
		.add(EnemyIdle, Chase, EnemyConditions.very_suspicious)
		.add(EnemyIdle, EnemyFear, EnemyConditions.fear)
		.add(EnemyIdle, EnemyPatrol, EnemyConditions.suspicious) 
		.add(EnemyIdle, EnemyDead, EnemyConditions.dead)
		
		.add(Chase, EnemyIdle, EnemyConditions.notsuspicious)
		.add(Chase, EnemyPatrol, EnemyConditions.not_very_suspicious)
		.add(Chase, EnemyDead, EnemyConditions.dead)
		
		.add(EnemyPatrol, EnemyIdle, EnemyConditions.notsuspicious)
		.add(EnemyPatrol, Chase, EnemyConditions.very_suspicious)
		.add(EnemyPatrol, EnemyDead, EnemyConditions.dead)
		
		
		.add(EnemyFear, EnemyIdle, EnemyConditions.calm_down)
		.add(EnemyFear, EnemyDead, EnemyConditions.dead)
		
		.start(EnemyIdle);
		
		//AI INIT
		_lastPlayerPositionKnown = new FlxPoint();
		_nullPosition = new FlxPoint();
		
		//RAYCAST SECTION 
		checkWallRay = true;
		
		//PARTICLE INIT
		_particleEmitter = new FlxEmitter(this.x, this.y + this.width / 2);
		_particleEmitter.makeParticles(1, 1, FlxColor.RED,1500);
		_particleEmitter.launchMode = FlxEmitterMode.CIRCLE;
		_particleEmitter.launchAngle.set( 0, -70);
		_particleEmitter.acceleration.start.min.y = 100;
		_particleEmitter.acceleration.start.max.y = 200;
		_particleEmitter.acceleration.end.min.y = 100;
		_particleEmitter.acceleration.end.max.y = 200;
		_particleEmitter.solid = true;
		
		
		
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
			if (_playerRepered)
			{
				if (tempoAvirer == 10)
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


class EnemyConditions
{
	
	public static function idle(Owner:Enemy)
	{
		return(!Owner.seePlayer);
	}

	public static function see(Owner:Enemy)
	{
		return(Owner.seePlayer && !Owner._isFearable);
	}
	
	public static function dead(Owner:Enemy)
	{
		return(Owner._health <= 0);
	}
	
	public static function suspicious(Owner:Enemy)
	{
		return(Owner._suspicion > 20 && !Owner._suspicious);
	}
	
	public static function very_suspicious(Owner:Enemy)
	{
		return(Owner._suspicion > 50 && Owner._suspicious);
	}
	
	public static function not_very_suspicious(Owner:Enemy)
	{
		return(Owner._suspicion <= 40);
	}
	
	public static function notsuspicious(Owner:Enemy)
	{
		return(Owner._suspicion <= 15);
	}
	
	public static function fear(Owner:Enemy)
	{
		return(Owner._suspicion < 20 && Owner._isFearable && Owner.seePlayer);
	}
	
	public static function calm_down(Owner:Enemy)
	{
		return(Owner._suspicion <= 5 && Owner._isFearable && !Owner.seePlayer);
	}
	
}

class EnemyPatrol extends FlxFSMState<Enemy>
{
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		trace("ENEMY ENTER PATROL MODE");
		owner._debugStateText.text = "PATROL";
		owner.animation.play("idle");
		owner._suspicious = true;
	}
	
	override public function update(elapsed:Float,owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		//CREER UN STATE ALERT
		var dir = owner.x - owner._lastPlayerPositionKnown.x;
		
		if (!owner._lastPlayerPositionKnown.equals(owner._nullPosition) && FlxMath.absInt(Std.int(dir)) != 0 )
		{
			//tentative de saut
			if (!owner.checkWallRay && (owner.y - owner._lastPlayerPositionKnown.y > 0))
			{
				owner.velocity.y =- 150; 
			}
			
			if (dir < 0)
			{
				owner.velocity.x = 20;
				owner.facing = FlxObject.RIGHT;
			}
			else
			{
				owner.velocity.x = -20;
				owner.facing = FlxObject.LEFT;
			}
		}
		else
		{
			owner.velocity.x = 0;
		}
	}
	
	override public function exit(owner: Enemy):Void
	{
	}
	
}



class EnemyIdle extends FlxFSMState<Enemy>
{
	override public function enter(owner:Enemy, fsm:FlxFSM<Enemy>):Void 
	{
		trace("ENEMY ENTER IDLE MODE");
		owner.animation.play("idle");
		owner._debugStateText.text = "IDLE";
		owner._suspicious = false;
	}
	
	
	override public function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void 
	{
		//RANDOM MOVE
		var rangeOfMove = 20;
		
		var maxDist = owner._initialPos.x + rangeOfMove;
		var maxDistO = owner._initialPos.x - rangeOfMove;
		
		var rand = FlxG.random.int(0, 2);
		
		switch (rand) 
		{
			case 0:
				owner.velocity.x = 0;
			case 1:
				owner.velocity.x = 10;
			case 2:
				owner.velocity.x = -10;
				
			default:
				
		}
		
		
		
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
	
	override public function exit(owner:Enemy):Void 
	{
		
	}
	
}


class EnemyFear extends FlxFSMState<Enemy>
{
	
	override public function enter(owner:Enemy, fsm:FlxFSM<Enemy>):Void 
	{
		trace("ENEMY ENTER FEAR MODE");
		owner._debugStateText.text = "FEAR";
		owner.animation.play("fear");
	}
	
	
	override public function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void 
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
	
	override public function exit(owner:Enemy):Void 
	{
		owner.velocity.x = 0;
	}
	
}


class EnemyAfterAlert extends FlxFSMState<Enemy>
{
	override public function enter(owner:Enemy, fsm:FlxFSM<Enemy>):Void 
	{
		trace("ENEMY ENTER PATROL MODE");
	}
	
	
	override public function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void 
	{
		
	}
	
	override public function exit(owner:Enemy):Void 
	{
		
	}
	
}

class Chase extends FlxFSMState<Enemy>
{
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		trace("ENEMY ENTER CHASING MODE");
		owner._debugStateText.text = "CHASE";
		owner.animation.play("walk");
		owner._playerRepered = true;
	}
	
	override public function update(elapsed:Float,owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		//trace("ENNEMY CHASE");
		if (!owner._player.is_bathing)
		{
			if (owner._distanceToPlayer <= 100  && owner._distanceToPlayer > 10)
			{
				owner.animation.play("walk");
				//tentative de saut
				if (!owner.checkWallRay && (owner.y - owner._player.y > 0))
				{
					owner.velocity.y =- 150; 
				}
				
				
				//aller vers le joueur
				var dir = owner.x - owner._player.x;
				if (dir < 0)
				{
					owner.velocity.x = 20;
					owner.facing = FlxObject.RIGHT;
				}
				else
				{
					owner.velocity.x = -20;
					owner.facing = FlxObject.LEFT;
				}
			}
			else if (owner._distanceToPlayer <= 10)
			{
				//Attack
				owner.animation.play("idle");
				trace("Launch attack");
				owner.velocity.x = 0;
			}
		}
		else
		{
			trace("OU EST IL PASSER ??");
		}
		
		
		
	}
	
	override public function exit(owner: Enemy):Void
	{
		owner.velocity.x = 0;
	}
}

class EnemyDead extends FlxFSMState<Enemy>
{
	var count = 0;
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
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
		owner._particleEmitter.start(false, 0.01,150);
	}
	
	override public function update(elapsed:Float,owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		if (owner.animation.finished && count == 0)
		{
			owner.animation.play("dieEnd");
			count++;
		}

	}
	
	override public function exit(owner: Enemy):Void
	{
		
	}
}