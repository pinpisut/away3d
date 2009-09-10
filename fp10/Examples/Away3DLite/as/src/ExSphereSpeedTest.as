/*

Basic scene setup example in Away3dLite

Demonstrates:

How to setup your own camera and scene, and apply it to a view.
How to add 3d objects to a scene.
How to update the view every frame.

Code by Rob Bateman & Katopz
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
katopz@sleepydesign.com
http://sleepydesign.com/

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package 
{
	import away3dlite.core.base.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
	
	/**
	 * FastTemplate example testing the maximum amount of faces rendered in a frame at 30fps
	 */
	public class ExSphereSpeedTest extends FastTemplate
	{
    	//signature swf
    	[Embed(source="assets/signature_lite_katopz.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		/**
		 * @inheritDoc
		 */
		protected override function onInit():void
		{
			title += " : Sphere speed test."; 
			
			camera.zoom = 15;
			camera.focus = 50;
			camera.z = -500;
			
			renderer.sortObjects = false;
			
			onMouseUp();
			onMouseUp();
			onMouseUp();
			onMouseUp();
			onMouseUp();
			onMouseUp();
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.MEDIUM;
			addChild(SignatureBitmap);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.CLICK, onMouseUp);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onPreRender():void
		{
			scene.z += ((view.height + scene.children.length*100) - scene.z) / 25;
			
			for each (var mesh:Mesh in scene.children) {
				mesh.rotationX++;
				mesh.rotationY++;
				mesh.rotationZ++;
			}
		}
		
		/**
		 * Listener function for mouse up event
		 */
		private function onMouseUp(event:MouseEvent = null):void
		{
			var sphere:Sphere = new Sphere();
			sphere.radius = 100;
			sphere.segmentsH = 20;
			sphere.segmentsW = 20;
			sphere.material = new BitmapFileMaterial("assets/earth.jpg");
			sphere.sortFaces = false;
			
			scene.addChild(sphere);

			var numChildren:int = scene.children.length;

			var i:int = 0;
			for each (var mesh:Mesh in scene.children) {
				mesh.material.debug = false;
				mesh.x = numChildren*50*Math.sin(2*Math.PI*i/numChildren);
				mesh.y = numChildren*50*Math.cos(2*Math.PI*i/numChildren);
				i++;
			}
		}
		
		/**
		 * Listener function for mouse down event
		 */
		private function onMouseDown(event:MouseEvent = null):void
		{
			for each (var mesh:Mesh in scene.children) {
				mesh.material.debug = true;
			}
		}
	}
}