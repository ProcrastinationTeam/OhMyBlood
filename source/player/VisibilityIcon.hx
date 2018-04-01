package player;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ...
 */
class VisibilityIcon extends FlxSprite 
{
	private var playerVisi : Int = 0;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Sprite:FlxGraphicAsset) 
	{
		super(X, Y);
		//this.loadGraphic(Sprite);
		this.loadGraphic("assets/images/visibilityIcon.png", true, 32, 32,false);
		this.animation.add("FullVisibility", [0], 30, true);
		this.animation.add("MiddleVisibility", [1], 30, true);
		this.animation.add("lowvi", [2], 30, true);
		
	}
	
	override public function update(elapsed:Float):Void
	{
	
		//VISIBILLITY SYSTEM
		if (playerVisi == 100)
		{
			this.animation.play("FullVisibility");
		}
		else if (playerVisi < 100 && playerVisi > 40)
		{
			this.animation.play("MiddleVisibility");
		}
		else
		{
			this.animation.play("lowvi");
		}
	}

	public function getPlayerVisibility(value:Int)
	{
		playerVisi = value;
		
	}
}