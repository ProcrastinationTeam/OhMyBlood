package npcs;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import player.Player;

/**
 * ...
 * @author ...
 */
class Enemy extends FlxSprite
{

		//TILEMAP
	public var _map:FlxTilemap;
	//USEFULL
	public var _player:Player;
	
		//PARTICLE SYSTEM
	public var _particleEmitter:FlxEmitter;
	
	public function new(?X:Float=0, ?Y:Float=0, map:FlxTilemap, player:Player) 
	{
		super(X, Y);
		_map = map;
		_player = player;
		
		
		//PARTICLE INIT
		_particleEmitter = new FlxEmitter(this.x, this.y + this.width / 2);
		_particleEmitter.makeParticles(1, 1, FlxColor.RED,1500);
		_particleEmitter.launchMode = FlxEmitterMode.CIRCLE;
		_particleEmitter.launchAngle.set( 0, -70);
		_particleEmitter.acceleration.start.min.y =0;
		_particleEmitter.acceleration.start.max.y = 0;
		_particleEmitter.acceleration.end.min.y = 1000;
		_particleEmitter.acceleration.end.max.y = 2000;
		_particleEmitter.acceleration.end.min.x = 0;
		_particleEmitter.acceleration.end.max.x = 0;
		
		_particleEmitter.solid = true;
		
	}
	
}