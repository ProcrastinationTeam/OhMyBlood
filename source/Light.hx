package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ...
 */
class Light extends FlxSprite 
{

	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y);
		this.loadGraphic("assets/images/light.png", true, 32, 128, false);
		//light.animation.add("breath", [0,1,2], 3);
		this.animation.add("breath", [0], 3);
		this.animation.play("breath");
		//lightingSystem.add(light);
		this.setPosition(60, 100);
	}
	
}