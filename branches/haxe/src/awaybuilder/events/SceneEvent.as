package awaybuilder.events{	import flash.events.Event;				public class SceneEvent extends Event	{		static public const RENDER : String = "SceneEvent.RENDER" ;								public function SceneEvent ( type : String , bubbles : Boolean = true , cancelable : Boolean = false )		{			super ( type , bubbles , cancelable ) ;		}	}}