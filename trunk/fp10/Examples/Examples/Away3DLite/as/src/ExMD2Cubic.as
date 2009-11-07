/*

Basic MD2 loading in Away3dLite

Demonstrates:

How to load an md2 file.
How to load a texture from an external image.
How to animate an md2 file.

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
	import away3dlite.animators.*;
	import away3dlite.core.utils.*;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
	
	/**
	 * MD2 example
	 */
	public class ExMD2Cubic extends FastTemplate
	{
    	//signature swf
    	[Embed(source="assets/signature_lite_katopz.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		private function onSuccess(event:Loader3DEvent):void
		{
			var model:MovieMesh = event.loader.handle as MovieMesh;
			model.play("walk");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : MD2 Example.";
			Debug.active = true;
			camera.z = -1500;
			
			var material:BitmapFileMaterial = new BitmapFileMaterial("assets/pg.png");
			material.smooth = true;
			
			var amount:uint = 3;
			var gap:int = 240;

			for (var i:int = 0; i < amount; ++i) {
				for (var j:int = 0; j < amount; ++j) {
					for (var k:int =0; k < amount; ++k) {
						var md2:MD2 = new MD2();
						md2.material = material;
						material.smooth = true;
						md2.scaling = 10;
						md2.centerMeshes = true;
						var loader:Loader3D = new Loader3D(); 
						loader.loadGeometry("assets/pg.md2", md2);
						loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
						
						loader.x = gap*i - amount*gap/2 + 100;
						loader.y = gap*j - amount*gap/2 + 200;
						loader.z = gap*k - amount*gap/2;
						
						view.scene.addChild(loader);
					}
				}
			}
			
			scene.rotationX = 30;
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.MEDIUM;
			addChild(SignatureBitmap);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			scene.rotationX = (mouseX - stage.stageWidth / 2) / 5;
			scene.rotationZ = (mouseY - stage.stageHeight / 2) / 5;
			scene.rotationY++;
			view.render();
		}
	}
}