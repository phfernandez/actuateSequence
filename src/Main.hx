package;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

import motion.Actuate;
import motion.easing.*;

import tweening.ActuateSequence;

/**
 * ...
 * @author Pedro Fernandez
 */
class Main extends Sprite 
{
	
	private var seq:ActuateSequence;
	
	public function new() 
	{
		super();
		
		var squareSize:Int;
		
		squareSize = 100;
		var square1 = new Shape ();
		square1.graphics.beginFill (0xFF0000, 0.5);
		square1.graphics.drawRect (0, 0, squareSize, squareSize);
		square1.graphics.endFill ();
		var sprite1:Sprite = new Sprite();
		square1.x = -square1.width / 2;
		square1.y = -square1.height / 2;
		sprite1.addChild (square1);
		sprite1.x = 150;
		sprite1.y = 150;
		addChild(sprite1);
		sprite1.name = "sprite1";
		
		squareSize = 200;
		var square2 = new Shape ();
		square2.graphics.beginFill (0x00FF00, 0.5);
		square2.graphics.drawRect (0, 0, squareSize, squareSize);
		square2.graphics.endFill ();
		var sprite2:Sprite = new Sprite();
		square2.x = -square2.width / 2;
		square2.y = -square2.height / 2;
		sprite2.addChild (square2);
		sprite2.x = 400;
		sprite2.y = 200;
		addChild(sprite2);
		sprite2.name = "sprite2";
		
		squareSize = 75;
		var square3 = new Shape ();
		square3.graphics.beginFill (0x0000FF, 0.5);
		square3.graphics.drawRect (0, 0, squareSize, squareSize);
		square3.graphics.endFill ();
		var sprite3:Sprite = new Sprite();
		square3.x = -square3.width / 2;
		square3.y = -square3.height / 2;
		sprite3.addChild (square3);
		sprite3.x = 700;
		sprite3.y = 200;
		addChild(sprite3);
		sprite3.name = "sprite3";
		
		
		var textFormat:TextFormat = new TextFormat("Arial", 24, 0x000000);
		
		var playText = new TextField ();
		playText.defaultTextFormat = textFormat;
		playText.autoSize = TextFieldAutoSize.LEFT;
		playText.text = "Play";
		playText.x = 20;
		playText.y = stage.stageHeight - 40;
		addChild (playText);
		playText.addEventListener(MouseEvent.CLICK, onClickPlayButton);
		
		var pauseText = new TextField ();
		pauseText.defaultTextFormat = textFormat;
		pauseText.autoSize = TextFieldAutoSize.LEFT;
		pauseText.text = "Pause";
		pauseText.x = playText.x + playText.width + 30;
		pauseText.y = stage.stageHeight - 40;
		addChild (pauseText);
		pauseText.addEventListener(MouseEvent.CLICK, onClickPauseButton);
		
		var stopText = new TextField ();
		stopText.defaultTextFormat = textFormat;
		stopText.autoSize = TextFieldAutoSize.LEFT;
		stopText.text = "Stop";
		stopText.x = pauseText.x + pauseText.width + 30;
		stopText.y = stage.stageHeight - 40;
		addChild (stopText);
		stopText.addEventListener(MouseEvent.CLICK, onClickStopButton);
		
		
		
		// ActuateSequence definition in Array
		var aSequence = new Array<Dynamic>();
		aSequence = [
			{ target:sprite1, duration:0.5, from: { alpha:0.0, x:"-=50", delay:0.25 } },
			{ target:sprite2, duration:0.5, from: { alpha:0.0, scaleX:2.0, scaleY:2.0 }, to: { alpha:1.0, scaleX:1.0, scaleY:1.0, delay: -0.25 } },
			{ target:sprite3, duration:0.75, from: { y:"+=150", rotation:60, delay: -0.25, ease:Elastic.easeOut } },
			
			{ target:sprite1, duration:0.5, to: { y:"+=400", delay:0.0, ease:Quad.easeIn } },
			{ target:sprite3, duration:0.5, to: { alpha:0.0, scaleX:3.0, scaleY:3.0, delay: -0.25, ease:Expo.easeIn } },
			{ target:sprite2, duration:1.0, to: { alpha:0.0, scaleX:2.0, scaleY:2.0, rotation:"+=200", delay: -0.25, ease:Expo.easeIn } }
		];
		
		seq = new ActuateSequence();
		seq.addEventListener( ActuateSequence.ON_COMPLETE_SEQUENCE, endSequence);
		seq.init(aSequence); // Init sequence first time
		
		seq.start(); // Start from the beginning
		
	}
	
	private function endSequence(e:Event = null):Void
	{
		//trace("endSequence");
	}
	
	
	function onClickPlayButton(e:MouseEvent):Void 
	{
		if (seq != null) seq.play();
	}
	
	function onClickStopButton(e:MouseEvent):Void 
	{
		if (seq != null) seq.stop();
	}
	
	function onClickPauseButton(e:MouseEvent):Void 
	{
		if (seq != null) seq.pause();
	}

}
