package away3d.core.light;

import away3d.core.base.Object3D;


/**
 * Interface for objects that provide lighting to the scene
 */
interface ILightProvider  {
	var debug(getDebug, setDebug) : Bool;
	var debugPrimitive(getDebugPrimitive, null) : Object3D;
	
	function light(consumer:ILightConsumer):Void;

	function getDebug():Bool;

	function setDebug(debug:Bool):Bool;

	function getDebugPrimitive():Object3D;

	

}

