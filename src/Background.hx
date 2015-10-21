package;

import openfl.display.Sprite;

/**
 * ...
 * @author FloZone
 */
class Background extends Sprite
{

	public function new() 
	{
		super();
		this.graphics.beginFill(0xffffff);
		this.graphics.drawRect(0, 0, 6, 40);
		this.graphics.endFill();
	}
	
}