﻿package away3d.core.ik{	import away3d.core.ik.Bone;	import away3d.core.ik.IKBase;	import flash.geom.Matrix;	import away3d.core.material.ColorMaterial;	import away3d.core.material.IMaterial;	import away3d.core.math.Number3D;	import away3d.core.ik.IKEvent;	import flash.display.Sprite;	import flash.events.EventDispatcher;	    public class Chain extends Sprite    {				public var _origin:Number3D;		private var _base:IKBase;		private var _baseid:String; 		public var _matrix:Matrix;				public var _aBones:Array;			   		function Chain(origin:Number3D, baseid:String, baseinstance:IKBase):void		{			this._origin = new Number3D(origin.x, origin.y, origin.z);			this._matrix = new Matrix();			this._aBones = new Array();			this._baseid = baseid;			this._base = baseinstance;			trace("new Chain");			this.addBaseListeners();		}		//EVENTS		//base events		private function addBaseListeners():void{			trace("listener is: BASE_POSITION"+this._baseid);			this._base.addEventListener("BASE_POSITION"+this._baseid, this.basePosition);		}		public function basePosition(e:IKEvent):void{			//trace("--> received base position update x: "+e.oData.position.x+", y: "+e.oData.position.y+", z: "+e.oData.position.z);			this._origin.x = e.oData.position.x;			this._origin.y = e.oData.position.y;			this._origin.z = e.oData.position.z;						var chainEvent:IKEvent = new IKEvent("CHAIN_POSITION"+this._id);			chainEvent.oData = {position:this._origin};			this.dispatchEvent(chainEvent);		}				//returns all bones in this chain		public function get bones():Array		{			return this._aBones;		}				//returns origin bone in this chain		public function get firstbone():Bone		{			return this._aBones[0];		}				//returns extremity bone in this chain		public function get lastbone():Bone		{			return this._aBones[this._aBones.length-1];		}				// overwrite all bones... might be handy for dynamic fill off the chains from xml or comparable...		public function set bones(abones:Array):void		{				this._aBones = new Array();			this._aBones = this._aBones.concat(abones);		}				public function addBone(x:Number,y:Number,z:Number, length:Number, extremity:Boolean, chainid:int, verticelist:Array, visible:Boolean = false, mat:IMaterial = null):Bone		{			trace("try add bone to chain..."+arguments);			try{				var start:Number3D = new Number3D(x, y, z);				var end:Number3D = new Number3D(x, y, z);				this._aBones.push(new Bone(start,end,length, extremity, chainid, this._aBones.length, verticelist, visible, mat));				if(extremity && this._aBones.length>1){					this._aBones[this._aBones.length-2].extremity = false				}				trace("chain adds bone... at "+(this._aBones.length-1));			}catch (e:Error){				trace("Error while adding bone to chain");			}			return this._aBones[this._aBones.length-1];		}				public function removeBone(index:int):void		{			this._aBones.splice(index, 1);		}				public function get matrix():Matrix		{			return this._matrix;		}				public function set matrix(mat:Matrix):void		{			this._matrix = mat;		}				public function get origin():Number3D		{			return this._origin;		}				public function set origin(norigin:Number3D):void		{			this._origin.x = norigin.x;			this._origin.y = norigin.y;			this._origin.z = norigin.z;		}    }}