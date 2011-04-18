﻿package{	import away3d.containers.ObjectContainer3D;	import away3d.containers.View3D;	import away3d.events.LoaderEvent;	import away3d.events.ResourceEvent;	import away3d.loading.ResourceManager;	import away3d.loading.parsers.AWD1Parser;		import flash.display.Sprite;	import flash.events.Event;		[SWF(width="800", height="450", frameRate="60", backgroundColor="#000000")]	public class LoaderAWD1Test extends Sprite	{		private var _view : View3D;		private var _container : ObjectContainer3D;				public function LoaderAWD1Test()		{			_view = new View3D();			_view.camera.z = -2000;			addChild(_view);						ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);			ResourceManager.instance.addEventListener(LoaderEvent.LOAD_ERROR, onResourceLoadingError);			ResourceManager.instance.addEventListener(LoaderEvent.LOAD_MAP_ERROR, onResourceMapsLoadingError);						var url:String = "assets/models/turtleawd1.awd";						// to load awd1 type file, pass the awd1 parser			// once awd2 parser is ready, it will no longer be required			ResourceManager.instance.getResource(url, false, new AWD1Parser(url));		}				private function onResourceRetrieved(e : ResourceEvent) : void		{			_container = ObjectContainer3D(e.resource);			_view.scene.addChild(_container);			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);		}				private function onResourceLoadingError(e:LoaderEvent) : void		{			trace("Oops, file loading failed");		}				private function onResourceMapsLoadingError(e:LoaderEvent) : void		{			trace("A map failed to load in this model: ["+e.url+"]");		}				private function handleEnterFrame(e : Event) : void		{			_container.rotationY += 5;			_view.render();		}	}}