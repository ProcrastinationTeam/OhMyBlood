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
class EnemyChaser extends Enemy 
{
	//FSM
	public var fsm:FlxFSM<EnemyChaser>;


	
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
	
	
	//DEBUG
	public var _debugText:FlxText;
	public var _debugStateText:FlxText;
	
	
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap, player:Player) 
	{
		//BASIC INIT
		super(X, Y, map, player);
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
		fsm = new FlxFSM<EnemyChaser>(this);
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
	
		
		if (_distanceToPlayer <= Tweaking.ennemyVisionDistance && dotProd < 0 &&  _map.ray(new FlxPoint(this.x,this.y), _player.getMidpoint()) && !_player.is_bathing && _player.visibility == 100)
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
	
	public static function idle(Owner:EnemyChaser)
	{
		return(!Owner.seePlayer);
	}

	public static function see(Owner:EnemyChaser)
	{
		return(Owner.seePlayer && !Owner._isFearable);
	}
	
	public static function dead(Owner:EnemyChaser)
	{
		return(Owner._health <= 0);
	}
	
	public static function suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion > 20 && !Owner._suspicious);
	}
	
	public static function very_suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion > 50 && Owner._suspicious);
	}
	
	public static function not_very_suspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 40);
	}
	
	public static function notsuspicious(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 15);
	}
	
	public static function fear(Owner:EnemyChaser)
	{
		return(Owner._suspicion < 20 && Owner._isFearable && Owner.seePlayer);
	}
	
	public static function calm_down(Owner:EnemyChaser)
	{
		return(Owner._suspicion <= 5 && Owner._isFearable && !Owner.seePlayer);
	}
	
}

class EnemyPatrol extends FlxFSMState<EnemyChaser>
{
	override public function enter(owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
	{
		trace("ENEMY ENTER PATROL MODE");
		owner._debugStateText.text = "PATROL";
		owner.animation.play("idle");
		owner._suspicious = true;
	}
	
	override public function update(elapsed:Float,owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
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
	
	override public function exit(owner: EnemyChaser):Void
	{
	}
	
}



class EnemyIdle extends FlxFSMState<EnemyChaser>
{
	var ticks:Int;
	var pathCheckpointReach:Bool;
	var destinationChoose:Bool;
	var initialXPos:Float;
	var finalXPos:Float;
	var rangeOfMove:Float;
	
	override public function enter(owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
	{
		trace("ENEMY ENTER IDLE MODE");
		owner.animation.play("idle");
		owner._debugStateText.text = "IDLE";
		owner._suspicious = false;
		
		rangeOfMove = 32.0;
		ticks = 0;
		pathCheckpointReach = false;
		destinationChoose = false;
	}
	
	
	override public function update(elapsed:Float, owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
	{
		// Look right for XX ticks then turn back look left and so on
		ticks++;
		if (ticks > 300)
		{
			if (owner.facing == FlxObject.LEFT)
			{
				owner.facing = FlxObject.RIGHT;
			}
			else if (owner.facing == FlxObject.RIGHT)
			{
				owner.facing = FlxObject.LEFT;
			}
			ticks = 0;
		}
		
		
		
		
		//RANDOM MOVE
		
		//var maxDist = owner._initialPos.x + rangeOfMove;
		//var maxDistO = owner._initialPos.x - rangeOfMove;
	/*	
		if (!destinationChoose)
		{
			initialXPos = owner.getPosition().x;
			
			destinationChoose = true;
			var rand = FlxG.random.int(1, 2);
			
			switch (rand) 
			{
				case 0:
					owner.velocity.x = 0;
				case 1:
					owner.velocity.x = 10;
					owner.facing = FlxObject.RIGHT;
					finalXPos = initialXPos + rangeOfMove;
				
				case 2:
					owner.velocity.x = -10;
					owner.facing = FlxObject.LEFT;
					finalXPos = initialXPos - rangeOfMove;
					
				default:
					
			}
			
		}	
		
		if (owner.velocity.x != 0)
		{
			owner.animation.play("walk");
			if (owner.velocity.x > 0)
			{
				if (owner.getPosition().x > finalXPos)
				{
					trace("VELOCITY POS");
					pathCheckpointReach = true;
					owner.velocity.x = 0;
				}
			}
			else if(owner.velocity.x < 0)
			{
				if ( owner.getPosition().x < finalXPos)
				{
					trace("VELOCITY NEG");
					pathCheckpointReach = true;
					owner.velocity.x = 0;
					
				}
			}
		}
		else
		{
			owner.animation.play("idle");
		}
		
		if (pathCheckpointReach)
		{
			ticks++;
			if (ticks == 40)
			{
				destinationChoose = false;
				pathCheckpointReach = false;
				ticks = 0;
			}
		}
		*/
		

	}
	
	override public function exit(owner:EnemyChaser):Void 
	{
		
	}
	
}


class EnemyFear extends FlxFSMState<EnemyChaser>
{
	
	override public function enter(owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
	{
		trace("ENEMY ENTER FEAR MODE");
		owner._debugStateText.text = "FEAR";
		owner.animation.play("fear");
	}
	
	
	override public function update(elapsed:Float, owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
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
	
	override public function exit(owner:EnemyChaser):Void 
	{
		owner.velocity.x = 0;
	}
	
}


class EnemyAfterAlert extends FlxFSMState<EnemyChaser>
{
	override public function enter(owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
	{
		trace("ENEMY ENTER PATROL MODE");
	}
	
	
	override public function update(elapsed:Float, owner:EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void 
	{
		
	}
	
	override public function exit(owner:EnemyChaser):Void 
	{
		
	}
	
}

class Chase extends FlxFSMState<EnemyChaser>
{
	override public function enter(owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
	{
		trace("ENEMY ENTER CHASING MODE");
		owner._debugStateText.text = "CHASE";
		owner.animation.play("walk");
		owner._playerRepered = true;
	}
	
	override public function update(elapsed:Float,owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
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
	
	override public function exit(owner: EnemyChaser):Void
	{
		owner.velocity.x = 0;
	}
}

class EnemyDead extends FlxFSMState<EnemyChaser>
{
	var count = 0;
	override public function enter(owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
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
	
	override public function update(elapsed:Float,owner: EnemyChaser, fsm:FlxFSM<EnemyChaser>):Void
	{
		if (owner.animation.finished && count == 0)
		{
			owner.animation.play("dieEnd");
			count++;
		}
		
		if (owner.animation.finished)
		{
			owner.active = false;
		}
		

	}
	
	override public function exit(owner: EnemyChaser):Void
	{
		
	}
}