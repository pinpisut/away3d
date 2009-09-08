package
{
	import away3dlite.core.geom.Plane3D;
	import away3dlite.lights.Light;
	import away3dlite.materials.WireframeMaterial;
	import away3dlite.materials.shaders.PhongColorMaterial;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.math.*;
	import jiglib.physics.*;
	import jiglib.physics.constraint.*;
	import jiglib.plugin.away3dlite.Away3DLiteMesh;
	import jiglib.templates.PhysicsTemplate;

	[SWF(backgroundColor="#666666",frameRate="30",quality="MEDIUM",width="800",height="600")]
	/**
	 * Example : Physics HingeJoint
	 *
	 * @see http://away3d.googlecode.com/svn/trunk/fp10/Away3DLite/src
	 * @see http://away3d.googlecode.com/svn/branches/JigLibLite/src
	 *
	 * @author katopz
	 */
	public class ExHingeJoint extends PhysicsTemplate
	{
		private var boxBody:Array;

		private var onDraging:Boolean = false;

		private var currDragBody:RigidBody;
		private var dragConstraint:JConstraintWorldPoint;
		private var planeToDragOn:Plane3D;

		private var light:Light;

		private var startMousePos:Vector3D;

		private var chain:Array;

		override protected function build():void
		{
			var jm:JMatrix3D = new JMatrix3D();
			var m:Matrix3D = JMatrix3D.getMatrix3D(jm); 
			var m2:Matrix3D = new Matrix3D();
			var jm2:JMatrix3D = JMatrix3D.getJMatrix3D(m2); 
			title += " | HingeJoint : Use mouse to drag red ball | ";

			camera.y = 1000;

			light = new Light();
			light.setPosition(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);

			init3D();

			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);

			JConfig.limitLinVelocities = 200;
			JConfig.numContactIterations = 8;
		}

		private function init3D():void
		{
			// TODO: use object hit instead of layer
			var layer:Sprite = new Sprite();
			view.addChild(layer);

			var sphere:RigidBody;
			var prevSphere:RigidBody;

			chain = [];
			for (var i:int = 0; i < 8; i++)
			{
				if (i == 0)
				{
					sphere = physics.createSphere(new PhongColorMaterial(light, 0xFF0000), 20, 3, 2);

					// draggable
					currDragBody = sphere;
					Away3DLiteMesh(sphere.skin).mesh.layer = layer;
				}
				else
				{
					sphere = physics.createSphere(new WireframeMaterial(), 20, 3, 2);
				}

				sphere.moveTo(new Vector3D(0, 130 + (25 * i + 25), 0));

				if (i != 0)
				{
					var pos1:Vector3D = JNumber3D.getScaleVector(Vector3D.Y_AXIS, -prevSphere.boundingSphere);
					var pos2:Vector3D = JNumber3D.getScaleVector(Vector3D.Y_AXIS, sphere.boundingSphere);

					//set up the hinge joints.
					chain[i] = new HingeJoint(prevSphere, sphere, Vector3D.X_AXIS, new Vector3D(0, 15, 0), 10, 30, 30, 0.1, 0.5);

					//disable some collisions between adjacent pairs
					sphere.disableCollisions(prevSphere);
				}

				prevSphere = sphere;
			}

			boxBody = [];
			for (i = 0; i < 16; i++)
			{
				boxBody[i] = physics.createCube(new WireframeMaterial(0xFFFFFF * Math.random()), 25, 25, 25);
				boxBody[i].moveTo(new Vector3D(500 * Math.random() - 500 * Math.random(), 500 + 500 * Math.random(), 500 * Math.random() - 500 * Math.random()));
			}

			physics.createSphere(new WireframeMaterial(0x00FF00), 50).moveTo(new Vector3D(300, 50, 50));

			layer.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
		}

		private function handleMousePress(event:MouseEvent):void
		{
			onDraging = true;
			var layer:Sprite = event.target as Sprite;

			startMousePos = new Vector3D(currDragBody.x, currDragBody.y, currDragBody.z);

			planeToDragOn = new Plane3D();
			planeToDragOn.fromNormalAndPoint(new Vector3D(0, 1, 0), new Vector3D(0, 0, -startMousePos.z));

			var p:Vector3D = currDragBody.currentState.position;
			var bodyPoint:Vector3D = startMousePos.subtract(new Vector3D(p.x, p.y, p.z));

			var a:Vector3D = new Vector3D(bodyPoint.x, bodyPoint.y, bodyPoint.z);
			var b:Vector3D = new Vector3D(startMousePos.x, startMousePos.y, startMousePos.z);

			dragConstraint = new JConstraintWorldPoint(currDragBody, a, b);
			physics.engine.addConstraint(dragConstraint);
		}

		// TODO:clean up/by pass
		private function handleMouseMove(event:MouseEvent):void
		{
			if (onDraging)
			{
				var ray:Vector3D = view.camera.unproject(view.mouseX, -view.mouseY);
				ray.add(new Vector3D(view.camera.x, view.camera.y, view.camera.z));

				var cameraVector3D:Vector3D = new Vector3D(view.camera.x, view.camera.y, view.camera.z);
				var rayVector3D:Vector3D = new Vector3D(ray.x, ray.y, ray.z);
				var intersectPoint:Vector3D = planeToDragOn.getIntersectionLine(cameraVector3D, rayVector3D);

				dragConstraint.worldPosition = new Vector3D(intersectPoint.x, intersectPoint.y, intersectPoint.z);
			}
		}

		private function handleMouseRelease(event:MouseEvent):void
		{
			if (onDraging)
			{
				onDraging = false;
				physics.engine.removeConstraint(dragConstraint);
				currDragBody.setActive();
			}
		}

		override protected function onPreRender():void
		{
			physics.step();

			camera.lookAt(Away3DLiteMesh(ground.skin).mesh.position, new Vector3D(0, 1, 0));
		}

		override protected function onEnterFrame(event:Event):void
		{
			// BUG : avoid shader bug...
			try
			{
				super.onEnterFrame(event);
			}
			catch (e:*)
			{
			}
		}
	}
}