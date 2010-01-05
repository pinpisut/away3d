package away3dlite.animators.bones;

import away3dlite.core.base.Object3D;
import away3dlite.containers.ObjectContainer3D;
import flash.Lib;

/**
 * Stores the varying transformations of a single <code>Bone</code> or <code>Object3D</code> object over the dureation of a bones animation
 * 
 * @see away3dlite.animators.BonesAnimator
 */
 class Channel
{
	private var i:Int;
	private var _index:Int;
	private var _length:Int;
	private var _oldlength:Int;
	
	public var name:String;
	public var target:Object3D;
	
	public var type:Array<String>;
	
	public var param:Array<Dynamic>;
	public var inTangent:Array<Array<Float>>;
	public var outTangent:Array<Array<Float>>;
	
	public var times:Array<Float>;
	public var interpolations:Array<Float>;
	
	#if !as3_original
	private var setFields:Hash<Dynamic>;
	private var lastLen:Int;
	#end
	
	public function new(name:String)
	{
		this.name = name;
		
		type = [];
		
		param = [];
		inTangent = [];
		outTangent = [];
		times = [];
		
		interpolations = [];
		
		setFields = new Hash<Dynamic>();
	}
	
	private function updateFields()
	{
		i = type.length;
		
		while (--i >= lastLen)
		{
			if (Reflect.hasField(target, "set_" + type[i]))
				setFields.set(type[i], Reflect.field(target, "set_" + type[i]));
		}
		lastLen = type.length;
	}
	
	/**
	 * Updates the channel's target with the data point at the given time in seconds.
	 * 
	 * @param	time						Defines the time in seconds of the playhead of the animation.
	 * @param	interpolate		[optional]	Defines whether the animation interpolates between channel points Defaults to true.
	 */
	public function update(time:Float, ?interpolate:Bool = true)
	{	
		if (target == null)
			return;
		
		if (lastLen != type.length)
			updateFields();
		i = type.length;
		
		if (time < times[0]) {
			while (i-- != 0)
			{
				var setField = setFields.get(type[i]);
				if (setField != null)
					setField(param[0][i]);
				else
					Reflect.setField(target, type[i], param[0][i]);
			}
		} else if (time > times[Std.int(times.length - 1)]) {
			while (i-- != 0)
			{
				var setField = setFields.get(type[i]);
				if (setField != null)
					setField(param[Std.int(times.length - 1)][i]);
				else
					Reflect.setField(target, type[i], param[Std.int(times.length - 1)][i]);
			}
		} else {
			_index = _length = _oldlength = times.length - 1;
			
			while (_length > 1)
			{
				_oldlength = _length;
				_length >>= 1;
				
				if (times[_index - _length] > time) {
					_index -= _length;
					_length = _oldlength - _length;
				}
			}
			
			_index--;
			
			while (i-- != 0) {
				if (type[i] == "transform") {
					target.transform.matrix3D = param[_index][i];
				} else if (type[i] == "visibility") {
					target.visible = param[_index][i] > 0;
				} else {
					if (interpolate)
					{
						var setValue = ((time - times[_index]) * param[Std.int(_index + 1)][i] + (times[Std.int(_index + 1)] - time) * param[_index][i]) / (times[Std.int(_index + 1)] - times[_index]);
						var setField = setFields.get(type[i]);
						if (setField != null)
							setField(setValue);
						else
							Reflect.setField(target, type[i], setValue);
					} else {
						var setValue = param[_index][i];
						var setField = setFields.get(type[i]);
						if (setField != null)
							setField(setValue);
						else
							Reflect.setField(target, type[i], setValue);
					}
				}
			}
		}
	}
	
	public function clone(object:ObjectContainer3D):Channel
	{
		var channel:Channel = new Channel(name);
		
		channel.target = Lib.as(object.getChildByName(name), Object3D);
		channel.type = type.copy();
		channel.param = param.copy();
		channel.inTangent = inTangent.copy();
		channel.outTangent = outTangent.copy();
		channel.times = times.copy();
		channel.interpolations = interpolations.copy();
		
		return channel;
	}
}