package tweening;

import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;

import motion.Actuate;
import motion.easing.*;

/**
 * ...
 * @author Pedro Fernandez
 */
class ActuateSequence extends EventDispatcher
{
	private var aUsedTargets:Map<String,Dynamic>;
	private var aOriginalTargets:Map<String,Dynamic>;
	private var aSequence:Array<Dynamic>;
	private var actuateFromProps:Dynamic;
	private var actuateToProps:Dynamic;
	public var playing:Bool = false;
	public var paused:Bool = false;
	
	public inline static var ON_COMPLETE_SEQUENCE:String = "ON_COMPLETE_SEQUENCE";
	
	
	
	public function new() 
	{
		super();
		aOriginalTargets = new Map<String,Dynamic>();
	}
	
	
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function init: Pass aSequence Array first time; Call without arguments to initialize/replay sequence
	// ---------------------------------------------------------------------------------------------------------------------------
	public function init(aSequence:Array<Dynamic> = null):Void
	{
		if (aSequence != null) 
		{
			aOriginalTargets = new Map<String,Dynamic>();
			this.aSequence = aSequence;
		}
		
		var tl_line:Dynamic;
		var tl_global_delay:Float = 0.0;
		var onCompleteFunction:Dynamic;
		
		aUsedTargets = new Map<String,Dynamic>(); // Init used targets each time the timeline initializes
		
		for (i in 0...this.aSequence.length)
		{
			
			tl_line = this.aSequence[i]; // Get current line of timeline with properties: target, duration, from, to
			
			// Default tween values
			var duration = Reflect.field(tl_line, "duration");
			var delay = 0.0;
			var ease = Sine.easeOut;
			
			var val:Dynamic = 0.0;
			var rel_val:Float = 0.0;
			
			var target:DisplayObject = cast( Reflect.field(tl_line, "target"), DisplayObject );
			var targetUsed:Bool = false;
			var originalTargetData:Dynamic;
			
			var from_data:Dynamic = Reflect.field(tl_line, "from");
			var to_data:Dynamic = Reflect.field(tl_line, "to");
			var fields_from:Array<String> = Reflect.fields ( from_data );
			var fields_to:Array<String> = Reflect.fields ( to_data );
			var from_alpha:Dynamic = 0.0;
			var to_alpha:Dynamic = 1.0;
			
			var has_from_data:Bool = false;
			
			// Init target with original values and save in Map table 
			if ( !aOriginalTargets.exists (target.name) )
			{
				var targetFromData:Dynamic = { };
				Reflect.setField (targetFromData, "target", target);
				Reflect.setField (targetFromData, "orig_x", target.x);
				Reflect.setField (targetFromData, "orig_y", target.y);
				Reflect.setField (targetFromData, "orig_scaleX", target.scaleX);
				Reflect.setField (targetFromData, "orig_scaleY", target.scaleY);
				Reflect.setField (targetFromData, "orig_rotation", target.rotation);
				Reflect.setField (targetFromData, "orig_alpha", target.alpha);
				
				if (from_data != null)
				{
					has_from_data = true;
					
					for (field in Reflect.fields (from_data)) {
						
						if ( field != "delay" && field != "ease" )
						{
							val = Reflect.field(from_data, field);
							if ( Std.is(val, String) )
							{
								if (val.indexOf("-=") != -1) 
								{
									val = Reflect.getProperty (target, field) - Std.parseFloat ( (val.split("-=")[1]) );
								}
								else if (val.indexOf("+=") != -1) 
								{
									val = Reflect.getProperty (target, field) + Std.parseFloat ( (val.split("+=")[1]) );
								}
							}
							
							Reflect.setField (targetFromData, "from_" + field, val);
						}
						
					}
					
				}
				
				Reflect.setField (targetFromData, "has_from_data", has_from_data);
				
				// Save in Map table
				aOriginalTargets.set ( target.name, targetFromData );
				
			}
			
			// Save target if previosly used in timeline
			if ( !aUsedTargets.exists (target.name) ) aUsedTargets.set (target.name, true); else targetUsed = true; // Mark target as used
			
			originalTargetData = aOriginalTargets.get(target.name);
			
			if (!targetUsed)
			{
				// Set target to initial positions
				for (field in Reflect.fields (originalTargetData)) 
				{
					if ( field.indexOf("orig_") != -1 )
					{
						val = Reflect.field(originalTargetData, field);
						Reflect.setProperty(target, field.split("orig_")[1], val);
					}
					
				}
				
			}
			
			
			
			if (from_data != null)
			{
				
				actuateFromProps = {};
				for (propertyFromName in fields_from) 
				{
					if ( propertyFromName == "delay" )
					{
						delay = Reflect.field(from_data, propertyFromName);
					}
					else if ( propertyFromName == "ease" )
					{
						ease = Reflect.field(from_data, propertyFromName);
					}
					else
					{
						val = Reflect.field(from_data, propertyFromName);
						if ( Std.is(val, String) )
						{
							if (val.indexOf("-=") != -1) 
							{
								val = Reflect.getProperty (target, propertyFromName) - Std.parseFloat ( (val.split("-=")[1]) );
							}
							else if (val.indexOf("+=") != -1) 
							{
								val = Reflect.getProperty (target, propertyFromName) + Std.parseFloat ( (val.split("+=")[1]) );
							}
						}
						
						Reflect.setField (actuateFromProps, propertyFromName, val);
					}
					
				}
				
				Actuate.apply ( target, actuateFromProps );
				
			}
			
			
			val = 0.0;
			actuateToProps = { };
			
			if (to_data != null)
			{

				for (propertyToName in fields_to) 
				{
					
					if ( propertyToName == "delay" )
					{
						delay = Reflect.field(to_data, propertyToName);
					}
					else if ( propertyToName == "ease" )
					{
						ease = Reflect.field(to_data, propertyToName);
					}
					else
					{
						val = Reflect.field(to_data, propertyToName);
						if ( Std.is(val, String) )
						{
							if (val.indexOf("-=") != -1) 
							{
								val = Reflect.getProperty (target, propertyToName) - Std.parseFloat ( (val.split("-=")[1]) );
							}
							else if (val.indexOf("+=") != -1) 
							{
								val = Reflect.getProperty (target, propertyToName) + Std.parseFloat ( (val.split("+=")[1]) );
							}
						}
						
						Reflect.setField (actuateToProps, propertyToName, val);
					}
					
				}
				
			}
			else
			{
				
				for (field in Reflect.fields (originalTargetData)) 
				{
					if ( field.indexOf("orig_") != -1 )
					{
						val = Reflect.field(originalTargetData, field);
						Reflect.setField(actuateToProps, field.split("orig_")[1], val);
					}
					
				}
				
				if (from_data != null)
				{
					from_alpha = Reflect.field(from_data, "alpha");
					if ( Std.is(from_alpha, Float) )
					{
						if ( from_alpha < 1.0 ) to_alpha = 1.0;
					}
				}
				else
				{
					to_alpha = originalTargetData.orig_alpha;
				}
				
				Reflect.setField(actuateToProps, "alpha", to_alpha);
				
			}
			
			if ( i == 0) tl_global_delay += delay; else tl_global_delay += delay + duration;
			if ( i == this.aSequence.length - 1 ) onCompleteFunction = endSequence; else onCompleteFunction = null;
			
			Actuate.tween ( target, duration, actuateToProps, false ).delay(tl_global_delay).ease(ease).onComplete(onCompleteFunction);
			
		}
		
		// Pause all sequence targets after timeline creation
		pauseSequenceTargets();
		
		playing = false;
		paused = false;
	}
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function reset: Resets all objects from this sequence animation to the starting positions
	// ---------------------------------------------------------------------------------------------------------------------------
	public function reset():Void
	{
		playing = false;
		paused = false;
		
		stopSequenceTargets();
		
		var target:DisplayObject;
		var originalTargetData:Dynamic;
		var val:Dynamic = 0.0;
		
		if (aSequence != null) 
		{
			
			for ( target_name in aOriginalTargets.keys() ) 
			{
				
				originalTargetData = aOriginalTargets.get(target_name);
				target = originalTargetData.target;
				
				
				// Reset original displayObject properties
				for (field in Reflect.fields (originalTargetData)) 
				{
					if ( field.indexOf("orig_") != -1 )
					{
						val = Reflect.field(originalTargetData, field);
						if (field == "orig_alpha") 
						{
							target.visible = true;
						}
						Reflect.setProperty(target, field.split("orig_")[1], val);
					}
					
				}
				
				if (originalTargetData.has_from_data)
				{
					
					// Reset "from" displayObject properties
					for (field in Reflect.fields (originalTargetData)) 
					{
						
						if ( field.indexOf("from_") != -1 )
						{
							if ( field != "has_from_data" )
							{
								val = Reflect.field(originalTargetData, field);
								if (field == "from_alpha") 
								{
									target.visible = true;
								}
								Reflect.setProperty(target, field.split("from_")[1], val);
							}
							
						}
						
					}
					
				}
				
				
			}
			
			
			
		}
	}
	
	private function pauseSequenceTargets():Void
	{
		var originalTargetData:Dynamic;
		var target:DisplayObject;
		for ( target_name in aOriginalTargets.keys() ) 
		{
			originalTargetData = aOriginalTargets.get(target_name);
			target = originalTargetData.target;
			Actuate.pause(target);
		}
	}
	
	private function stopSequenceTargets():Void
	{
		var originalTargetData:Dynamic;
		var target:DisplayObject;
		for ( target_name in aOriginalTargets.keys() ) 
		{
			originalTargetData = aOriginalTargets.get(target_name);
			target = originalTargetData.target;
			Actuate.stop(target);
		}
	}
	
	private function resumeSequenceTargets():Void
	{
		var originalTargetData:Dynamic;
		var target:DisplayObject;
		for ( target_name in aOriginalTargets.keys() ) 
		{
			originalTargetData = aOriginalTargets.get(target_name);
			target = originalTargetData.target;
			Actuate.resume(target);
		}
	}
	
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function start: Play sequence animation always from the beginning
	// ---------------------------------------------------------------------------------------------------------------------------
	public function start():Void
	{
		init();
		
		playing = true;
		paused = false;
		
		resumeSequenceTargets();
	}
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function play: Play sequence animation from the beginning or resumes playback from current position (if paused)
	// ---------------------------------------------------------------------------------------------------------------------------
	public function play():Void
	{
		if (!playing && !paused)
		{
			init();
		}
		playing = true;
		paused = false;
		
		resumeSequenceTargets();
	}
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function pause: Pauses sequence animation
	// ---------------------------------------------------------------------------------------------------------------------------
	public function pause():Void
	{
		if (playing)
		{
			playing = false;
			paused = true;
			
			pauseSequenceTargets();
		}
		
	}
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function stop: Stop sequence animation resetting values to first frame (similar to gotoAndPlay(0) in gsap timeline)
	// ---------------------------------------------------------------------------------------------------------------------------
	public function stop():Void
	{
		playing = false;
		paused = false;
		
		reset();
	}
	
	// ---------------------------------------------------------------------------------------------------------------------------
	// Function endSequence: Event called onComplete; 
	// Dispatches event ON_COMPLETE_SEQUENCE to control end of timeline from outside
	// ---------------------------------------------------------------------------------------------------------------------------
	private function endSequence():Void
	{
		playing = false;
		paused = false;
		
		dispatchEvent( new Event(ActuateSequence.ON_COMPLETE_SEQUENCE) );
	}
	
	
}