package away3dlite.primitives{	import away3dlite.arcane;	import away3dlite.core.base.*;	import away3dlite.materials.*;		import flash.geom.Vector3D;
	use namespace arcane;	/**	 * Creates a 3D BoundingBox primitive.	 */	public class BoundingBox extends Cube6	{		/** 0 = none, 1 = AABB (Axis Aligned Bounding Box), 2 = OBB (Oriented Bounding Box)*/		public var boundingType:int = 0;		private var _targetMesh:Mesh;		/**		 *		 * Creates a new <code>BoundingBox</code> object.		 *		 * @param targetMesh	Target this Mesh to monitor bounding size		 * @param boundingType	0 = none, 1 = AABB (Axis Aligned Bounding Box), 2 = OBB (Oriented Bounding Box)		 * @param wireColor		border color		 * @param wireAlpha		border alpha		 * @param thickness		border thickness		 *		 */		public function BoundingBox(targetMesh:Mesh, boundingType:int = 1, wireColor:* = null, wireAlpha:Number = 1, thickness:Number = 1)		{			_targetMesh = targetMesh;			this.boundingType = boundingType;			super(new QuadWireframeMaterial(wireColor, wireAlpha, thickness), 0, 0, 0);			// bind to target mesh			_targetMesh.useBoundingBox = true;			_targetMesh.onBoundingBoxUpdate = applyBoundingBox;			type = "BoundingBox";			url = "primitive";		}		/**		 *		 * Apply BoundingBox to <code>Cube6</code> vertices.		 *		 * @param minBounding		 * @param maxBounding		 *		 */		private function applyBoundingBox(minBounding:Vector3D, maxBounding:Vector3D):void		{			// apply			applyBoundingBoxVertices(minBounding, maxBounding);						// OBB			// to target space			_targetMesh.transform.matrix3D.transformVectors(_vertices, _vertices);						// to box space			transform.matrix3D.transformVectors(_vertices, _vertices);						// AABB : update box vertices			if (boundingType == 1)			{				updateBoundingBox(this.minBounding = new Vector3D, this.maxBounding = new Vector3D);				applyBoundingBoxVertices(this.minBounding, this.maxBounding);			}		}		private function applyBoundingBoxVertices(minBounding:Vector3D, maxBounding:Vector3D):void		{			var minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number;			minX = minBounding.x;			minY = minBounding.y;			minZ = minBounding.z;			maxX = maxBounding.x;			maxY = maxBounding.y;			maxZ = maxBounding.z;			var i:int = 0;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = maxY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = minZ;			_vertices[int(i++)] = maxX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;			_vertices[int(i++)] = minX;			_vertices[int(i++)] = minY;			_vertices[int(i++)] = maxZ;		}	}}