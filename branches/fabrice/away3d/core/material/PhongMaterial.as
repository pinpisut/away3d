﻿package away3d.core.material{		import away3d.core.*;    import away3d.core.math.*;    import away3d.core.scene.*;    import away3d.core.draw.*;    import away3d.core.render.*;    import away3d.core.utils.*;    import flash.display.*;    import flash.geom.*;	import away3d.core.material.*;		import away3d.core.mesh.Vertex;    public class PhongMaterial implements ITriangleMaterial, IUVMaterial    {        public var bitmap:BitmapData;		public var lightmap:BitmapData;		public var fxbitmap:BitmapData;		public var rect:Rectangle;        public var smooth:Boolean;        public var debug:Boolean;        public var repeat:Boolean;		public var light:String;		private var aFX:Array;		//private var sprite1:Sprite;		//private var sprite2:Sprite;				private var eTri0x:Number;		private var eTri0y:Number;		private var eTri1x:Number;		private var eTri1y:Number;		private var eTri2x:Number;		private var eTri2y:Number;				internal var mapping:Matrix;		                public function get width():Number        {            return bitmap.width;        }        public function get height():Number        {            return bitmap.height;        }				public function get ewidth():Number        {            return lightmap.width;        }        public function get eheight():Number        {            return lightmap.height;        }                public function PhongMaterial(bitmap:BitmapData, init:Object = null, afx:Array = null)        {            this.bitmap = bitmap;			            init = Init.parse(init);            smooth = init.getBoolean("smooth", false);            debug = init.getBoolean("debug", false);            repeat = init.getBoolean("repeat", false);			light = init.getString("light", "");			//hier check on 			this.generateMap();			if(afx != null){				this.fxbitmap = bitmap.clone();				this.rect = new Rectangle(0,0,1,1);				this.aFX = new Array();				this.aFX = afx.concat();			}        }		private function generateMap():void		{			this.lightmap = new BitmapData(width, height, true, 0x00000000);			var tmpsprite = new Sprite();			var mat:Matrix = new Matrix();			mat.createGradientBox(width, height, 0, 0, 0);			var color:uint = (AmbientLight == null)? 0xFFFFFF : AmbientLight.lightcolor;			//var color:uint = 0xFF0000;			tmpsprite.graphics.beginGradientFill(GradientType.RADIAL, [color, color], [100, 0], [0x00, 0xFF], mat, "pad");			tmpsprite.graphics.drawRect(0,0,width,height);			this.lightmap.draw(tmpsprite,null,null,null,this.lightmap.rect,true);		}		        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void        {			var mapping:Matrix = tri.texturemapping || tri.transformUV(this);			//in case we need to render as double face			if(this.bitmap != null){				var source:BitmapData = this.bitmap; 				//fx				if(this.aFX != null){					source = this.fxbitmap;					if(normal == null){						normal = AmbientLight.getNormal([tri.v0, tri.v1, tri.v2]);					}					var CT:ColorTransform;					if(tri.uvrect == null){						tri.transformUV(this);					}					for(var i:int = 0;i<this.aFX.length;i++){ 							this.aFX[i].apply(i,this.bitmap, source, tri.uvrect, normal, CT, session.sprite); 					}				}				session.renderTriangleBitmap(source, mapping, tri.v0, tri.v1, tri.v2, false, false, session.graphics);			}						var normal:Object = null;			 			var onorm:Object = new Object;			var norm:Number3D;						var facenorm:Number3D;			var average:Array;			var xnorm:Number;			var ynorm:Number;			var znorm:Number;						// see if the projection is front			var face_orientation:Boolean = this.isFront(tri.v0, tri.v1, tri.v2);			// lets rock and roll!			for(var j:int = 1;j<4;j++){				try{										xnorm = 0;					ynorm = 0;					znorm = 0;					average = tri.face["average0"+j];										for(i = 0;i< average.length;i++){						 						 //if(face_orientation){							//  if(this.isBack(average[i].projection.a, average[i].projection.b, average[i].projection.c)){								 								facenorm = average[i].normal;								//facenorm = average[i].normal.rotate(average[i].projection.view)								xnorm += facenorm.x;								ynorm += facenorm.y;								znorm += facenorm.z;							// }						//}						/*						} else{							if(this.isBack(average[i].projection.a, average[i].projection.b, average[i].projection.c)){								facenorm = average[i].normal;								xnorm += facenorm.x;								ynorm += facenorm.y;								znorm += facenorm.z;							}						}						*/					}										onorm["norm"+j] = new Number3D(xnorm/average.length, ynorm/average.length, znorm/average.length);									} catch(e:Error){					onorm["norm"+j] = new Number3D(1,1,1);				}						}			//translate normals to uv 2D projection			eTri0x =  ewidth * ((onorm.norm1.x*.5) + .5);			eTri0y =  eheight * (1 - ((-(onorm.norm1.y)*.5) + .5));			eTri1x =  ewidth * ((onorm.norm2.x*.5) + .5);			eTri1y =  eheight * (1 - ((-(onorm.norm2.y)*.5) + .5));			eTri2x =  ewidth * ((onorm.norm3.x*.5) + .5);			eTri2y =  eheight * (1 - ((-(onorm.norm3.y)*.5) + .5));			// generates new projection			var normalmapping:Matrix = new Matrix(eTri1x - eTri0x, eTri1y - eTri0y, eTri2x - eTri0x, eTri2y - eTri0y, eTri0x, eTri0y);            normalmapping.invert();            			session.renderTriangleBitmap(this.lightmap, normalmapping, tri.v0, tri.v1, tri.v2, false, false, session.graphics2);						// ambient light			if(light == "flat" && this.bitmap != null){				var ambient:Number;				var flatlightcolor:Number;				var a:Number;				var r:Number;				var g:Number;				var b:Number;				try{					normal = AmbientLight.getNormal([tri.v0, tri.v1, tri.v2]);					flatlightcolor = AmbientLight.getPolygonColor([tri.v0, tri.v1, tri.v2], AmbientLight.lightcolor, normal);										ambient = AmbientLight.ambientvalue;					 					//a = -255 + ((flatlightcolor >> 24 & 0xFF)*2)+ambient;					r = -255 + ((flatlightcolor >> 16 & 0xFF)*2)+ambient;					g = -255 + ((flatlightcolor >> 8 & 0xFF)*2)+ambient;					b = -255 + ((flatlightcolor & 0xFF)*2)+ambient;										session.sprite.transform.colorTransform = new ColorTransform(1,1,1,1,r,g,b,1);									} catch(er:Error){					trace("bitmapMaterial Flat color error: "+er.message);				}							}						//debug = true;			if (debug){               session.renderTriangleLine(2, 0x8800FF, 1, tri.v0, tri.v1, tri.v2);			}        }				private function isFront(v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):Boolean		{			return (v2.x - v0.x)*(v2.y - v0.y) < (v1.x-v2.x)* (v1.y-v2.y)		}				private function isBack(v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):Boolean		{			return (v2.x - v0.x)*(v2.y - v0.y) > (v1.x-v2.x)* (v1.y-v2.y)		}         public function get visible():Boolean        {            return true;        }     }}