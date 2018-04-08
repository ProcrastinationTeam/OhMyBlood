package;


import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import npcs.Enemy;
import npcs.npcs.EnemyFearable;
import Lighting;
import player.Player;
import npcs.npcs.EnemyChaser;
using flixel.util.FlxSpriteUtil;
using StringTools;

class PlayState extends FlxState
{
	private var _player : Player;
	
	// PLAYER GAME TEXT
	public var _actionText:FlxText;
	
	// INPUT BOOL
	private var _editMode : Bool;

	
	
	// ENNEMY LIST
	private var _enemyList : FlxTypedGroup<Enemy>;
	private var _enemy : EnemyChaser;
	private var _ennemyPosList : Array<FlxPoint>;
	private var _enemyF : EnemyFearable;
	
	// ladder
	private var _ladderList: FlxTypedGroup<FlxObject>;
	
	
	
	// TILEMAP 
	private var _map:FlxTilemap;
	private var _mapTable:Array<FlxColor>;
	private static inline var TILE_WIDTH:Int = 16;
	private static inline var TILE_HEIGHT:Int = 16;
	private var currentTileID:Int;
	
	
	
	// DEBUG TEXT
	private var _info:String = "Current State: {STATE} \n";
	private var _accX:String = "Acceleration X: {ACCX} \n";
	private var _accY:String = "Acceleration Y: {ACCY} \n";
	private var _velX:String = "Velocity X: {VELX} \n";
	private var _velY:String = "Velocity Y: {VELY} \n";
	private var _highRay:String = "High Ray : {THIGH} \n";
	private var _lowRay:String = "Low Ray : {TLOW} \n";
	private var _downLeftRay:String = "Down Left Ray: {DL} \n";
	private var _downRightRay:String = "Down Right Ray: {DR} \n";
	private var _upLeftRay:String = "Up Left Ray: {UL} \n";
	private var _upRightRay:String = "Up Right Ray: {UR} \n";
	private var _currentLeftTile:String = "Current Left Tile : {CurrentLeftTile} \n";
	private var _currentRightTile:String = "Current Right Tile : {CurrentRightTile} \n";
	
	private var _txtInfo:FlxText;
	private var _editModeTxt:FlxText;
	private var _EnemyInfo:FlxText;
	
	
	//CAMERA SYSTEM
	private var _camera : FlxCamera;
	//private var _camera : FlxCameraFollowStyle;
	
	//LIGHTING SYSTEM
	private var light: FlxSprite;
	private var bloodLight: FlxSprite;
	private var enemyBloodLight: FlxSprite;
	private var lightingSystem: Lighting;
	private var lightingSystem2: Lighting;
	private var lightingSystemBB: Lighting;
	
	
	
	private var _slainableEnemies : Array<Enemy>;
	
	override public function create():Void
	{
		super.create();
		bgColor = 0xff661166;
	
		//UI AND TEXT INIT
		_actionText = new FlxText(0,0, 80);
		//info.scrollFactor.set(0, 0); 
		_actionText.borderColor = 0xff000000;
		_actionText.borderStyle = SHADOW;
		_actionText.text = "SLAIN";
		_actionText.visible = false;
		
		_txtInfo = new FlxText(16, 16, -1, _info);
		_txtInfo.color = FlxColor.YELLOW;
		_txtInfo.visible = false;
		
		
		_editModeTxt = new FlxText(150, 20, -1, "EDIT MODE");
		_editModeTxt.color = FlxColor.GREEN;
		_editModeTxt.visible = false;
		
		_editMode = false;
		
		var playerpos = new FlxPoint(0, 0);
		_ennemyPosList = new Array<FlxPoint>();
	
		//ladder generation
		_ladderList = new FlxTypedGroup<FlxObject>();
		
		currentTileID = 1;
		_mapTable = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.BROWN, FlxColor.PURPLE, FlxColor.RED, FlxColor.CYAN ];
		_map = GenerateLevel("assets/data/fullMap.png", "assets/images/tiles2.png", playerpos);
		
		
		
		
		
		//INDISPENSABLE POUR QUE LE JEU CHARGE (FAIRE EN SORTE QU'IL SOIT PLUS GRAND QUE L'ENSEMBLE DES MAPS LOAD)
		FlxG.worldBounds.set(0, 0, _map.width, _map.height);

		_player = new Player(playerpos.x, playerpos.y, _map);
		
		//Enemy instanciation
		_enemyList = new FlxTypedGroup<Enemy>();
		_enemy = new EnemyChaser(_ennemyPosList[0].x, _ennemyPosList[0].y, _map, _player); 
		
		//test de l'ennemi qui a peur ( a supprimer)
		_enemyF = new EnemyFearable(_ennemyPosList[0].x - 20 , _ennemyPosList[0].y, _map, _player);
		_enemyList.add(_enemy);
		//_enemyList.add(_enemyF);
		
		

		
		//SIMPLE CAMERA A MODIFIER POUR LA RENDRE BIEN COOL
		this.camera.follow(_player, SCREEN_BY_SCREEN, 0.2);
		this.camera.snapToTarget();
		
		
	
	
		
		
		_slainableEnemies = [];
		
		
		//LIGHTING SYSTEM
		lightingSystem = new Lighting();
		lightingSystem.alpha = 0.9; // or whatever
		//lighting.blue = 20;   // for example
		lightingSystem.color = FlxColor.BLACK;
		
		
		
		light = new FlxSprite();
		light.loadGraphic("assets/images/light.png", true, 32, 128, false);
		light.animation.add("breath", [0], 3);
		light.animation.play("breath");
		light.setPosition(140, 100);
		lightingSystem.add(light);
		
		var light2 = Reflect.copy(light);
		light2.setPosition(180, 100);
		lightingSystem.add(light2);
		
		var light3 = Reflect.copy(light);
		light3.setPosition(220, 100);
		lightingSystem.add(light3);
		
		lightingSystem2 = new Lighting();
		lightingSystem2.alpha = 0.9; // or whatever
		//lighting.blue = 20;   // for example
		lightingSystem2.color = FlxColor.BLACK;
		
		var spawnlight = new FlxSprite();
		spawnlight.loadGraphic("assets/images/lantern.png", true, 64, 64, false);
		spawnlight.animation.add("r", [0,2, 1],3);
		spawnlight.animation.play("r");
		lightingSystem.add(spawnlight);
		spawnlight.setPosition(16, 6);
		
		//LIGHTING SYSTEM 2 (BLOOD BATH) // couleur R48 B3 G3 ou R69 B2 G2
		lightingSystemBB = new Lighting();
		lightingSystemBB.alpha = 1.0; // or whatever
		lightingSystemBB.blue = 2;   // for example
		lightingSystemBB.green = 2;   // for example
		lightingSystemBB.red = 69;   // for example
		//lightingSystemBB.color = FlxColor.RED;
		
		
		
		bloodLight = new FlxSprite();
		bloodLight.loadGraphic("assets/images/splash.png", true, 32, 32, false);
		bloodLight.animation.add("breath", [0], 3);
		bloodLight.animation.play("breath");
		lightingSystemBB.add(bloodLight);
		
		
		enemyBloodLight = new FlxSprite();
		enemyBloodLight.loadGraphic("assets/images/heart.png", true, 16, 16, false);
		enemyBloodLight.animation.add("breath", [0,1], 2);
		enemyBloodLight.animation.play("breath");
		lightingSystemBB.add(enemyBloodLight);
		
		
		
		add(_map);
		add(_ladderList);
		add(_enemyList);

		add(_player);
		
		add(_player.canvas);
		add(_player.canvas2);
		add(_player.canvas3);
		add(_player.canvas4);
		add(_player.canvas5);
		add(_player.canvas6);
		add(_player.biteHitbox);
		
		add(lightingSystem);
		//add(lightingSystem2);
		add(lightingSystemBB);
		
		add(_player.visibilityIcon);
		
		//DEBUG VA DISPARAITRE
		_EnemyInfo = _enemy._debugText;
		//+ _enemy._debugStateText;
		add(_EnemyInfo);
		//add(_enemy._debugText);
		//add(_enemy._debugStateText);
		
		
		//ADD UI
		add(_actionText);
		
		add(_txtInfo);
		add(_editModeTxt);
		
		
	}

	override public function update(elapsed:Float):Void
	{
		// TEST LIGHT
		if (_player.is_bathing)
		{
			lightingSystem.visible = false;
			lightingSystemBB.visible = true;
			bloodLight.setPosition(_player.x-14, _player.y-16);
			enemyBloodLight.setPosition(_enemy.x,_enemy.y);
		}
		else
		{
			lightingSystem.visible = true;
			lightingSystemBB.visible = false;
		}
		
		
		
		
		// VISIBILITY SYSTEM
		if (!FlxG.overlap(_player, lightingSystem, LightCalculation))
		{
			_player.visibility = 0;
		}
		
		
		// INPUT
		if (FlxG.mouse.pressed && _editMode)
		{
			//Rendre la map modifiable
			_map.setTile(Std.int(FlxG.mouse.x / TILE_WIDTH), Std.int(FlxG.mouse.y / TILE_HEIGHT), currentTileID, true);
		}
		
		if (FlxG.keys.justPressed.PLUS)
		{
			changeCurrentTile();
		}
		
		if (FlxG.keys.justPressed.SHIFT)
		{
			_editModeTxt.visible = !_editModeTxt.visible;
			_editMode = !_editMode;
		}
		
		if (FlxG.keys.justPressed.NUMPADZERO)
		{
			_txtInfo.visible = !_txtInfo.visible;
			_EnemyInfo.visible = ! _EnemyInfo.visible ;
		}
		

		
		// ladder input
		if (_player.on_ladder && !_player.grab_ladder  && FlxG.keys.justPressed.E)
		{
			_player.grab_ladder = true;
			trace("LADDER GRAB");
		}
		else if (_player.grab_ladder && (FlxG.keys.justPressed.E || !_player.on_ladder))
		{
			_player.grab_ladder = false;
		}
		
		
		
		// C'est degeu mais c'est que du debug
		_editModeTxt.setPosition(this.camera.scroll.x + 150, this.camera.scroll.y + 20);
		_txtInfo.setPosition( this.camera.scroll.x + 16, this.camera.scroll.y + 16);
		
		_txtInfo.text = _info.replace("{STATE}", Type.getClassName(_player.fsm.stateClass));
		_txtInfo.text += _accX.replace("{ACCX}", Std.string(_player.acceleration.x));
		_txtInfo.text += _accY.replace("{ACCY}", Std.string(_player.acceleration.y));
		_txtInfo.text += _velX.replace("{VELX}", Std.string(_player.velocity.x));
		_txtInfo.text += _velY.replace("{VELY}", Std.string(_player.velocity.y));
		_txtInfo.text += _highRay.replace("{THIGH}", Std.string(_player.sideHighRay));
		_txtInfo.text += _lowRay.replace("{TLOW}", Std.string(_player.sideLowRay));
		_txtInfo.text += _downLeftRay.replace("{DL}", Std.string(_player.downLeftRay));
		_txtInfo.text += _downRightRay.replace("{DR}", Std.string(_player.downRightRay));
		_txtInfo.text += _upRightRay.replace("{UR}", Std.string(_player.upRightRay));
		_txtInfo.text += _upLeftRay.replace("{UL}", Std.string(_player.upLeftRay));
		_txtInfo.text += _currentLeftTile.replace("{CurrentLeftTile}", Std.string(_player.currentLeftTile));
		_txtInfo.text += _currentRightTile.replace("{CurrentRightTile}", Std.string(_player.currentRightTile));
		
		if (FlxG.keys.anyJustPressed([FlxKey.R]))
		{
			FlxG.resetState();
		}
		
		//OVERLAP AND COLLIDE
		FlxG.collide(_player, _map);
		FlxG.collide(_enemyList, _map);
		FlxG.collide(_enemyF, _map);
		
		//Mettre en place un systeme pour que chaque enemy de la liste puisse add son particule emitter
		FlxG.collide(_enemy._particleEmitter, _map, disableVelocity);
		
		
		if (FlxG.overlap(_player, _ladderList))
		{
			_player.on_ladder = true;
			//trace("LADDER");
			//_player.acceleration.y = 0;
		} else {
			_player.on_ladder = false;
			_player.acceleration.y = _player.GRAVITY; 
		}
		
		_slainableEnemies = [];
		
		if (_player.is_bathing) {
			if (!FlxG.overlap(_player, _enemyList, EnemySlainable))
			{
				_actionText.visible = false;
			}
			else
			{
				trace("OVERLAP");
			}
		}
		
		if (!FlxG.overlap(_player.biteHitbox, _enemyF, EnemySlainable))
		{
			_actionText.visible = false;
		}
		
		
		if (FlxG.keys.justPressed.E) {
			for (enemy in _slainableEnemies) {
				
				add(enemy._particleEmitter);
				enemy.kill();	
			}
		}
		
		
		
		
		super.update(elapsed);
	}
	
	
	public function ladderOverlap(player:FlxObject) : Bool
	{
		return true;
	}
	
	
	////CALLBACK OVERLAP CONTIENT UN INPUT A MODIFIER 
	//public function CanSlain(owner:Player,enemy:Enemy)
	//{
		//_actionText.setPosition(enemy.x-10, enemy.y - 15);
		//_actionText.visible = true;
		//
		////SLAIN ENEMY
		//if (FlxG.keys.justPressed.E)
		//{
			//add(enemy._particleEmitter);
			//enemy.kill();	
		//}
	//}
	
	public function LightCalculation(player:Player,light:FlxSprite)
	{
		

		var checkPoint = new FlxPoint(light.getMidpoint().x, player.getMidpoint().y);
		var playerMidPoint = new FlxPoint(player.getMidpoint().x, player.getMidpoint().y);
		var yolo = Math.sqrt((checkPoint.x - playerMidPoint.x) * (checkPoint.x - playerMidPoint.x)  + (checkPoint.y - playerMidPoint.y) *(checkPoint.y - playerMidPoint.y));
		if (yolo > 25)
		{
			
		}
		if (yolo > 20)
		{
			_player.visibility = 25;
		}
		else if (yolo < 20 && yolo > 16)
		{
			_player.visibility = 50;
		}
		else if (yolo <= 16)
		{
			_player.visibility = 100;
		}
	
	}
	
	
	//Pour les particules mais à supprimer
	public function disableVelocity(part:FlxEmitter,map:FlxObject)
	{
		//part.immovable = true;
		//part.acceleration.
		
	}
	
	
	
	//CALLBACK OVERLAP CONTIENT UN INPUT A MODIFIER 
	public function EnemySlainable(owner:Player,enemy:EnemyChaser)
	{
		_actionText.setPosition(enemy.x-10, enemy.y - 15);
		_actionText.visible = true;
		_slainableEnemies.push(enemy);
	}
	
	public function EnemyBackstab(owner:Player,enemy:EnemyChaser)
	{
		if (enemy.facing == owner.facing)
		{
			_actionText.setPosition(enemy.x-10, enemy.y - 15);
			_actionText.visible = true;
			_slainableEnemies.push(enemy);
		}
		
	}
	
	
	//ALGO GENERATION MAP
	
	public function GenerateLevel(imageMapPath:String, imageTilePath:String, playerPosR: FlxPoint):FlxTilemap
	{ 
		
		//var mapTable = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.BROWN, FlxColor.GRAY, FlxColor.RED];
		var map = new FlxTilemap();
	
		//VERSION  WITHOUT AUTO TILES
		map.loadMapFromGraphic(imageMapPath, false, 1, _mapTable, imageTilePath, 16, 16);
		
		//VERSION AVEC AUTO TILES
		//map.loadMapFromGraphic(imageMapPath, false, 1, _mapTable, imageTilePath, 16, 16, AUTO);
		
		// No collision on ladder actually
		map.setTileProperties(3, FlxObject.NONE);
		
		var ar:Array<Int> = map.getTileInstances(3);
		var posArray:Array<FlxPoint> = new Array<FlxPoint>();
		for (a in ar)
		{
			map.getTileByIndex(a);
			var pos = map.getTileCoordsByIndex(a);
			posArray.push(pos);
		}
		
		posArray.sort(function(a, b): Int {
			if (a.y < b.y) return -1;
			else if (a.y > b.y) return 1;
			return 0;
		});
		
		trace(posArray.toString());
		
		var obj:FlxObject = new FlxObject(posArray[0].x-8, posArray[0].y-8, 16, (posArray[posArray.length-1].y-posArray[0].y + 16));
		_ladderList.add(obj);
		
		
	
		trace("LVL WIDTH : " + map.widthInTiles);
		trace("LVL HEIGHT : " + map.heightInTiles);
		
		//Chargement de la position de départ du joueur
		
		var playerPos:Array<FlxPoint> = map.getTileCoords(_mapTable.length-1, false);
		//player = new Hero(playerPos[0].x, playerPos[0].y);
		
		playerPosR.set(playerPos[0].x, playerPos[0].y);
		
		//Remove de la case propre au joueur
		var playerTiles:Array<Int> = map.getTileInstances(_mapTable.length-1);
		var playerTile:Int = playerTiles[0];
		map.setTileByIndex(playerTile, 0, true);
		
		_ennemyPosList = map.getTileCoords(_mapTable.length - 2, false);
		
		var enemyTiles:Array<Int> = map.getTileInstances(_mapTable.length - 2);
		for (tile in enemyTiles)
		{
			map.setTileByIndex(tile, 0, true);
		}
		
		//var halfTile:Array<FlxPoint> = map.getTileCoords(mapTable.length - 2, false);
		//var halfTile:Array<Int> = map.getTileInstances(mapTable.length - 2);
		//trace("TILE VALUE : " + halfTile.length);
		////
		//var myTile:FlxTile = new FlxTile(map, 15, 16, 8, true, FlxObject.ANY);
		//var myTileB:FlxTileblock = new FlxTileblock(0, 0, 16, 8);
		//trace("MY TILE : " + myTile.index);
		//
		//for (i in halfTile)
		//{
			//
		////	map.setTileByIndex(i,;
		//}
	//
		//map.setTileProperties(mapTable.length - 2, FlxObject.ANY, halfTileCallback);
	//	map.setTileByIndex(halfTile,
		
		return map;
	}
	
	
	public function changeCurrentTile()
	{
		currentTileID++;
		
		if (currentTileID > _mapTable.length - 1)
		{
			currentTileID = 0;
		}
		
	}
	
}
