package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
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
	
	//IA var
	public var _nullPosition : FlxPoint;
	public var _lastPlayerPositionKnown:FlxPoint;
	public var _distanceToPlayer:Int;
	
	public var checkWallRay:Bool;
	
	
	//PARTICLE SYSTEM
	public var _particleEmitter:FlxEmitter;
	
	
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap, player:Player) 
	{
		//BASIC INIT
		super(X, Y);
		_map = map;
		_player = player;
		
		//GRAPHICS INIT
		this.loadGraphic("assets/images/enemy.png", true, 16, 16, false);
		
		this.setFacingFlip(FlxObject.RIGHT, false, false);
		this.setFacingFlip(FlxObject.LEFT, true, false);
		this.facing = FlxObject.RIGHT;
		
		this.animation.add("idle", [0]);
		this.animation.add("walk", [0, 1], 6, true);
		this.animation.play("idle");
		
		
		//PHYSICS INIT
		this.setSize(8, 16);
		this.offset.set(4, 0);
		acceleration.y = 500;
		this.maxVelocity.set(150, 500);
		
		//FSM INIT
		fsm = new FlxFSM<Enemy>(this);
		fsm.transitions
		.add(EnemyIdle, Chase, EnemyConditions.see)
		.add(Chase, EnemyIdle, EnemyConditions.idle)
		.add(EnemyIdle, EnemyDead, EnemyConditions.dead)
		.add(Chase, EnemyDead, EnemyConditions.dead)
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
		
		
	}
	
	override public function update(elapsed:Float):Void
	{
		//trace("LAST POS KNOWN : " + this._lastPlayerPositionKnown);
		if (this.facing == FlxObject.RIGHT)
		{
			checkWallRay = this._map.ray(new FlxPoint(this.x,this.y+10), new FlxPoint(this.x + 10, this.y+10), 10);
		}
		else
		{
			checkWallRay = this._map.ray(new FlxPoint(this.x,this.y+10), new FlxPoint(this.x - 10, this.y+10), 10); 
		}
		
		
		//trace("WALL RAY : " + checkWallRay);
		
		checkEnemyVision();
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
		
		//calcul de distance nécessaire
		_distanceToPlayer = FlxMath.distanceBetween(this, _player);
		//trace("DISTANCE DU JOUEUR : " + _distanceToPlayer);
		
		if (_distanceToPlayer <= 100 &&  _map.ray(new FlxPoint(this.x,this.y), _player.getMidpoint()) && !_player.is_bathing )
		{
			seePlayer = true;
			_lastPlayerPositionKnown = _player.getPosition();
		}
		else
		{
			seePlayer = false;
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
		return(Owner.seePlayer);
	}
	
	public static function dead(Owner:Enemy)
	{
		return(Owner._health <= 0);
	}
	
}

class EnemyIdle extends FlxFSMState<Enemy>
{
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		trace("ENEMY ENTER IDLE MODE");
		owner.animation.play("idle");
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
	}
	
	override public function exit(owner: Enemy):Void
	{
	}
	

	
	
}

class Chase extends FlxFSMState<Enemy>
{
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		trace("ENEMY ENTER CHASING MODE");
		owner.animation.play("walk");
	}
	
	override public function update(elapsed:Float,owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		//trace("ENNEMY CHASE");
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
	
	override public function exit(owner: Enemy):Void
	{
		owner.velocity.x = 0;
	}
}

class EnemyDead extends FlxFSMState<Enemy>
{
	override public function enter(owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		trace("I'm DEAD");	
		owner.allowCollisions = FlxObject.NONE;
		owner.velocity.x  = 0;
		owner.velocity.y  = 0;
		owner.acceleration.x = 0;
		owner.acceleration.y = 0;
		owner._particleEmitter.setPosition(owner.x + owner.width / 2, owner.y + 3 );
		owner._particleEmitter.start(false, 0.01);
	}
	
	override public function update(elapsed:Float,owner: Enemy, fsm:FlxFSM<Enemy>):Void
	{
		 
	}
	
	override public function exit(owner: Enemy):Void
	{
		
	}
}