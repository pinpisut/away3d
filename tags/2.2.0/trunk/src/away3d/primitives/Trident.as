﻿package away3d.primitives{		import away3d.containers.*;	import away3d.core.base.*;	import away3d.core.math.*;	import away3d.extrusions.*;	import away3d.materials.*;        /**    * Creates an axis trident.    */ 	public class Trident extends ObjectContainer3D	{				/**		 * Creates a new <code>Trident</code> object.		 *		 * @param	 len				The length of the trident axes. Default is 1000.		 * @param	 showLetters	If the Trident should display the letters X. Y and Z.		 */		 		public function Trident(len:Number = 1000, showLetters:Boolean = false)		{			buildTrident(len, showLetters);		}				private function buildTrident(len:Number, showLetters:Boolean):void		{						var scaleH:Number = len/10;			var scaleW:Number = len/20;			var offset:Number = len+scaleW;						var matx:WireframeMaterial = new WireframeMaterial( 0xFF0000, {width:0});			var maty:WireframeMaterial = new WireframeMaterial( 0x00FF00, {width:0});			var matz:WireframeMaterial = new WireframeMaterial( 0x0000FF, {width:0});			var lineX:LineSegment = new LineSegment({material:matx});			var lineY:LineSegment = new LineSegment({material:maty});			var lineZ:LineSegment = new LineSegment({material:matz});						var pijlx:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:matx});			pijlx.rotationZ = -90;			pijlx.z = 0;			pijlx.x = offset;			pijlx.y = 0;						var pijly:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:maty});			pijly.y = offset;						var pijlz:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:matz});			pijlz.rotationX = -90;			pijlz.z = offset;			pijlz.x = 0;			pijlz.y = 0;			addChild(pijlx);			addChild(pijly);			addChild(pijlz);			//x			lineX.start = new Vertex(0,0,0);			lineX.end = new Vertex(len,0,0);			addChild(lineX);			//y			lineY.start = new Vertex(0,0,0);			lineY.end = new Vertex(0,len,0);			addChild(lineY);			//z			lineZ.start = new Vertex(0,0,0);			lineZ.end = new Vertex(0,0,len);			addChild(lineZ);									if(showLetters){								//x				var scl15:Number = scaleW*1.5;				var sclh3:Number = scaleH*3;				var sclh2:Number = scaleH*2;				var sclh34:Number = scaleH*3.4;				var x1:LineSegment = new LineSegment({material:matx});				x1.start = new Vertex(len+sclh3, scl15 , 0);				x1.end = new Vertex(len+sclh2, -scl15 , 0);				var x2:LineSegment = new LineSegment({material:matx});				x2.start = new Vertex(len+sclh2, scl15 , 0);				x2.end = new Vertex(len+sclh3, -scl15 , 0);								addChild(x1);				addChild(x2);				//y				var y1:LineSegment = new LineSegment({material:maty});				var y2:LineSegment = new LineSegment({material:maty});				var y3:LineSegment = new LineSegment({material:maty});				var cross:Number = len+(sclh2) + (  ((len+sclh34) - (len+sclh2)) /3  * 2);				y1.start = new Vertex(-scaleW*1.2, len+sclh34,0);				y1.end = new Vertex( 0, cross, 0);				y2.start = new Vertex(scaleW*1.2, len+sclh34,0);				y2.end = new Vertex( 0, cross, 0);				y3.start = new Vertex( 0, cross, 0);				y3.end = new Vertex( 0, len+sclh2, 0);								addChild(y1);				addChild(y2);				addChild(y3);				//z				var z1:LineSegment = new LineSegment({material:matz});				var z2:LineSegment = new LineSegment({material:matz});				var z3:LineSegment = new LineSegment({material:matz});								z1.start = new Vertex(0, scl15, len+sclh3);				z2.end = new Vertex(0, -scl15, len+sclh2);											z1.end = new Vertex(0, scl15, len+sclh2);				z2.start = new Vertex(0, -scl15, len+sclh3);					z3.start = z2.end;				z3.end = z1.start;								addChild(z1);				addChild(z2);				addChild(z3);			}		}			}}