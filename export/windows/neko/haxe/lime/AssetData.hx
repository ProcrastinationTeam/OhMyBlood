package lime;


import lime.utils.Assets;


class AssetData {

	private static var initialized:Bool = false;
	
	public static var library = new #if haxe3 Map <String, #else Hash <#end LibraryType> ();
	public static var path = new #if haxe3 Map <String, #else Hash <#end String> ();
	public static var type = new #if haxe3 Map <String, #else Hash <#end AssetType> ();	
	
	public static function initialize():Void {
		
		if (!initialized) {
			
			path.set ("assets/data/data-goes-here.txt", "assets/data/data-goes-here.txt");
			type.set ("assets/data/data-goes-here.txt", Reflect.field (AssetType, "text".toUpperCase ()));
			path.set ("assets/data/fullMap.ase", "assets/data/fullMap.ase");
			type.set ("assets/data/fullMap.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/data/fullMap.png", "assets/data/fullMap.png");
			type.set ("assets/data/fullMap.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/data/fullMap2.ase", "assets/data/fullMap2.ase");
			type.set ("assets/data/fullMap2.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/data/fullMap2.png", "assets/data/fullMap2.png");
			type.set ("assets/data/fullMap2.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/data/level0.png", "assets/data/level0.png");
			type.set ("assets/data/level0.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/data/level1.png", "assets/data/level1.png");
			type.set ("assets/data/level1.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/data/testMap.ase", "assets/data/testMap.ase");
			type.set ("assets/data/testMap.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/data/testMap.png", "assets/data/testMap.png");
			type.set ("assets/data/testMap.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/data/testMap2.ase", "assets/data/testMap2.ase");
			type.set ("assets/data/testMap2.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/data/testMapB.ase", "assets/data/testMapB.ase");
			type.set ("assets/data/testMapB.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/images/autotiles.png", "assets/images/autotiles.png");
			type.set ("assets/images/autotiles.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/char.png", "assets/images/char.png");
			type.set ("assets/images/char.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/enemy.png", "assets/images/enemy.png");
			type.set ("assets/images/enemy.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/galletvania_example.png", "assets/images/galletvania_example.png");
			type.set ("assets/images/galletvania_example.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/galletvania_tiles.png", "assets/images/galletvania_tiles.png");
			type.set ("assets/images/galletvania_tiles.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/hero - Copie.png", "assets/images/hero - Copie.png");
			type.set ("assets/images/hero - Copie.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/hero.ase", "assets/images/hero.ase");
			type.set ("assets/images/hero.ase", Reflect.field (AssetType, "binary".toUpperCase ()));
			path.set ("assets/images/hero.png", "assets/images/hero.png");
			type.set ("assets/images/hero.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/images-go-here.txt", "assets/images/images-go-here.txt");
			type.set ("assets/images/images-go-here.txt", Reflect.field (AssetType, "text".toUpperCase ()));
			path.set ("assets/images/level.png", "assets/images/level.png");
			type.set ("assets/images/level.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/MisterDougy.png", "assets/images/MisterDougy.png");
			type.set ("assets/images/MisterDougy.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/tiles.png", "assets/images/tiles.png");
			type.set ("assets/images/tiles.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/images/tilesInvert.png", "assets/images/tilesInvert.png");
			type.set ("assets/images/tilesInvert.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("assets/music/music-goes-here.txt", "assets/music/music-goes-here.txt");
			type.set ("assets/music/music-goes-here.txt", Reflect.field (AssetType, "text".toUpperCase ()));
			path.set ("assets/sounds/sounds-go-here.txt", "assets/sounds/sounds-go-here.txt");
			type.set ("assets/sounds/sounds-go-here.txt", Reflect.field (AssetType, "text".toUpperCase ()));
			path.set ("flixel/sounds/beep.ogg", "flixel/sounds/beep.ogg");
			type.set ("flixel/sounds/beep.ogg", Reflect.field (AssetType, "sound".toUpperCase ()));
			path.set ("flixel/sounds/flixel.ogg", "flixel/sounds/flixel.ogg");
			type.set ("flixel/sounds/flixel.ogg", Reflect.field (AssetType, "sound".toUpperCase ()));
			path.set ("flixel/fonts/nokiafc22.ttf", "flixel/fonts/nokiafc22.ttf");
			type.set ("flixel/fonts/nokiafc22.ttf", Reflect.field (AssetType, "font".toUpperCase ()));
			path.set ("flixel/fonts/monsterrat.ttf", "flixel/fonts/monsterrat.ttf");
			type.set ("flixel/fonts/monsterrat.ttf", Reflect.field (AssetType, "font".toUpperCase ()));
			path.set ("flixel/images/ui/button.png", "flixel/images/ui/button.png");
			type.set ("flixel/images/ui/button.png", Reflect.field (AssetType, "image".toUpperCase ()));
			path.set ("flixel/images/logo/default.png", "flixel/images/logo/default.png");
			type.set ("flixel/images/logo/default.png", Reflect.field (AssetType, "image".toUpperCase ()));
			
			
			initialized = true;
			
		} //!initialized
		
	} //initialize
	
	
} //AssetData
