package away3d.core.geom
{
	import away3d.core.graphs.BSPTree;
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.materials.ITriangleMaterial;
	
	use namespace arcane;
	
	/**
	 * NGon is an object describing a shape in 3D of any number of points
	 */
	public final class NGon
	{
		public var vertices : Vector.<Vertex>;
		public var uvs : Vector.<UV>;
		
		public var normal : Number3D;
		public var plane : Plane3D;
		public var material : ITriangleMaterial;
		
		// used during splitting etc
		private var _edgePlane : Plane3D = new Plane3D();
		private var _edge : Number3D = new Number3D();
		private var _edgeNormal : Number3D = new Number3D();
		
		private static var _newVerts : Vector.<Vertex>;
		private static var _newUVs : Vector.<UV>;
		
		/**
		 * Creates an NGon object
		 */
		public function NGon()
		{
			
		}
		
		/**
		 * Inverts the NGon
		 */
		public function invert() : void
		{
			var len : int = vertices.length;
			var newVertices : Vector.<Vertex> = new Vector.<Vertex>(len);
			var i : int = len;
			var j : int = 0;
			
			plane.a = -plane.a;
			plane.b = -plane.b;
			plane.c = -plane.c;
			plane.d = -plane.d;
			
			while (--i >= 0)
				newVertices[j++] = vertices[i];
			
			vertices = newVertices;
		}
		
		/**
		 * Classifies on which side of a plane this NGon falls
		 */
		public function classifyToPlane(compPlane : Plane3D) : int
		{
			var numPos : int;
			var numNeg : int;
			var numDoubt : int;
			var len : int = vertices.length;
			var dist : Number;
			var v : Vertex;
			var i : int = len;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					dist = a*vertices[i]._x + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					dist = b*vertices[i]._y + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					dist = c*vertices[i]._z + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					dist = a*v._x + b*v._y + c*v._z + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			
			if (numDoubt == len)
				return -2;
			if (numPos > 0 && numNeg == 0)
				return Plane3D.FRONT;
			if (numNeg > 0 && numPos == 0)
				return Plane3D.BACK;
			
			return Plane3D.INTERSECT;
		}
		
		/**
		 * Returns true if the NGon lies on the given plane
		 * 
		 * @private
		 */
		public function isCoinciding(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			var dist : Number;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					dist = a*vertices[i]._x + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					dist = b*vertices[i]._y + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					dist = c*vertices[i]._z + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					dist = a*v._x + b*v._y + c*v._z + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			
			return true;
		}
		
		/**
		 * Returns true if either in front of plane or intersecting
		 * 
		 * @private
		 */
		public function classifyForPortalFront(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					if(a*vertices[i]._x + d > BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					if(b*vertices[i]._y + d > BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					if(c*vertices[i]._z + d > BSPTree.EPSILON)
						return true;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					if (a*v._x + b*v._y + c*v._z + d > BSPTree.EPSILON)
						return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Returns true if either behind plane or intersecting
		 * 
		 * @private
		 */
		public function classifyForPortalBack(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
				
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					if(a*vertices[i]._x + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					if(b*vertices[i]._y + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					if(c*vertices[i]._z + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					if (a*v._x + b*v._y + c*v._z + d < -BSPTree.EPSILON)
						return true;
				}
			}
			return false;
		}
		
		/**
		 * Returns true if either in front of plane or intersecting
		 * 
		 * @private
		 */
		public function isOutAntiPenumbra(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
				
			// anti-penumbrae have no alignment info, skip tests
			while (--i >= 0) {
				v = vertices[i];
				if (compPlane.a*v._x + compPlane.b*v._y + compPlane.c*v._z + compPlane.d > BSPTree.EPSILON)
					return false;
			}
			return true;
		}
		
		/**
		 * Creates a duplicate of this NGon
		 */
		public function clone() : NGon
		{
			var c : NGon = new NGon();
			c.vertices = vertices.concat();
			if (uvs) c.uvs = uvs.concat();
			c.material = material;
			c.plane = new Plane3D(plane.a, plane.b, plane.c, plane.d);
			c.plane._alignment = plane._alignment;
			return c;
		}
		
		/**
		 * Triangulates the NGon
		 */
		public function triangulate() : Vector.<Face>
		{
			var len : int = vertices.length - 1;
			if (len < 1) return null;
			var tris : Vector.<Face> = new Vector.<Face>();
			var v0 : Vertex = vertices[0], v1 : Vertex, v2 : Vertex;
			var uv0 : UV, uv1 : UV, uv2 : UV;
			var j : int = -1;
			var eps : Number = BSPTree.EPSILON*BSPTree.EPSILON;
			
			if (uvs) uv0 = uvs[0];
			
			for (var i : int = 1; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[i+1];
				if (uvs) uv1 = uvs[i];
				if (uvs) uv2 = uvs[i+1];
				
				// check if collinear (caused by t-junctions), would create empty triangle otherwise
				_tempU.x = v1.x-v0.x;
				_tempU.y = v1.y-v0.y;
				_tempU.z = v1.z-v0.z;
				_tempV.x = v2.x-v0.x;
				_tempV.y = v2.y-v0.y;
				_tempV.z = v2.z-v0.z;
				_tempC.cross(_tempU, _tempV);
				
				if (_tempC.modulo2 > eps)
					tris[++j] = new Face(v0, v1, v2, material, uv0, uv1, uv2);
			}
			
			return tris;
		}
		
		/**
		 * Converts a Face object to an NGon
		 */
		public function fromTriangle(face : Face) : void
		{
			var triPlane : Plane3D = face.plane;
			vertices = new Vector.<Vertex>();
			uvs = new Vector.<UV>();
			vertices[0] = face.v0;
			vertices[1] = face.v1;
			vertices[2] = face.v2;
			uvs[0] = face.uv0;
			uvs[1] = face.uv1;
			uvs[2] = face.uv2;
			normal = face.normal;
			plane = new Plane3D(triPlane.a, triPlane.b, triPlane.c, triPlane.d);
			plane._alignment = triPlane._alignment;
			material = face.material;
		}
		
		/**
		 * Splits the ngon into two according to a split plane
		 * 
		 * @return Two new polygons. The first is on the positive side of the split plane, the second on the negative.
		 */
		public function split(splitPlane : Plane3D) : Vector.<NGon>
		{
			var ngons : Vector.<NGon> = new Vector.<NGon>(2);
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex;
			var posNGon : NGon = new NGon();
			var negNGon : NGon = new NGon();
			var posVerts : Vector.<Vertex>;
			var negVerts : Vector.<Vertex>;
			var posUV : Vector.<UV>;
			var negUV : Vector.<UV>;
			var j : int;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			var i : int = len;
			
			ngons[0] = posNGon;
			ngons[1] = negNGon;
			negNGon.plane = posNGon.plane = plane;
			negNGon.normal = posNGon.normal = normal;
			negNGon.material = posNGon.material = material;
			posVerts = posNGon.vertices = new Vector.<Vertex>();
			negVerts = negNGon.vertices = new Vector.<Vertex>();
			
			if (uvs) {
				posUV = posNGon.uvs = new Vector.<UV>();
				negUV = negNGon.uvs = new Vector.<UV>();
			}
			
			v1 = vertices[0];
			if (splitPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = splitPlane.a*v1._x + splitPlane.d;
			else if (splitPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = splitPlane.b*v1._y + splitPlane.d;
			else if (splitPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = splitPlane.c*v1._z + splitPlane.d;
			else
				d0 = d2 = splitPlane.a*v1._x + splitPlane.b*v1._y + splitPlane.c*v1._z + splitPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
			
			j = 1;
			for (i = 0; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[j];
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (splitPlane._alignment == Plane3D.X_AXIS)
						d2 = splitPlane.a*v2._x + splitPlane.d;
					else if (splitPlane._alignment == Plane3D.Y_AXIS)
						d2 = splitPlane.b*v2._y + splitPlane.d;
					else if (splitPlane._alignment == Plane3D.Z_AXIS)
						d2 = splitPlane.c*v2._z + splitPlane.d;
					else
						d2 = splitPlane.a*v2._x + splitPlane.b*v2._y + splitPlane.c*v2._z + splitPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 >= 0) {
					posVerts.push(v1);
					if (uvs) posUV.push(uvs[i]);
				}
				if (d1 <= 0) {
					negVerts.push(v1);
					if (uvs) negUV.push(uvs[i]);
				}
				
				if (d1*d2 < 0) {
					if (uvs) splitEdge(splitPlane, v1, v2, uvs[i], uvs[j], posNGon, negNGon);
					else splitEdge(splitPlane, v1, v2, null, null, posNGon, negNGon);
				}
				
				if (++j == len) j = 0;
			}
			
			if (posVerts.length < 3) ngons[0] = null;
			if (negVerts.length < 3) ngons[1] = null;
			
			return ngons;
		}
		
		/**
		 * Trims the NGon to the front side of a plane
		 */
		public function trim(trimPlane : Plane3D) : void
		{
			//if (vertices.length < 3) return;
			
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV;
			var j : int;
			var i : int;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			
			if (!_newVerts) _newVerts = new Vector.<Vertex>();
			if (uvs && !_newUVs) _newUVs = new Vector.<UV>();
			
			v1 = vertices[0];
			if (trimPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = trimPlane.a*v1._x + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = trimPlane.b*v1._y + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = trimPlane.c*v1._z + trimPlane.d;
			else
				d0 = d2 = trimPlane.a*v1._x + trimPlane.b*v1._y + trimPlane.c*v1._z + trimPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d0 = d2 = 0;
			
			j = 1;
			i = 0;
			
			v2 = vertices[0];
			if (uvs) uv2 = uvs[0];
			
			do {
				v1 = v2;
				v2 = vertices[j];
				if (uvs) {
					uv1 = uv2;
					uv2 = uvs[j];
				}
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (trimPlane._alignment == Plane3D.X_AXIS)
						d2 = trimPlane.a*v2._x + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Y_AXIS)
						d2 = trimPlane.b*v2._y + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Z_AXIS)
						d2 = trimPlane.c*v2._z + trimPlane.d;
					else
						d2 = trimPlane.a*v2._x + trimPlane.b*v2._y + trimPlane.c*v2._z + trimPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 >= 0) {
					_newVerts.push(v1);
					if (uvs) _newUVs.push(uv1);
				}
				
				if (d1*d2 < 0)
					trimEdge(trimPlane, v1, v2, uv1, uv2, _newVerts, _newUVs);
				
				if (++j == len) j = 0;
			} while (++i < len);
			
			var vTemp : Vector.<Vertex>;
			var uvTemp : Vector.<UV>;
			
			vTemp = vertices;
			vertices = _newVerts;
			_newVerts = vTemp;
			_newVerts.length = 0;
			
			if (uvs) {
				uvTemp = uvs;
				uvs = _newUVs;
				_newUVs = uvTemp;
				_newUVs.length = 0;
			}
			
//			if (vertices.length >= 3)
//				removeColinears();
		}
		
		/**
		 * Trims the NGon to the back side of a plane
		 */
		public function trimBack(trimPlane : Plane3D) : void
		{
//			if (vertices.length < 3) return;
			
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV;
			var j : int;
			var i : int = len;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			
			if (!_newVerts) _newVerts = new Vector.<Vertex>();
			if (uvs && !_newUVs) _newUVs = new Vector.<UV>();
			
			v1 = vertices[0];
			if (trimPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = trimPlane.a*v1._x + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = trimPlane.b*v1._y + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = trimPlane.c*v1._z + trimPlane.d;
			else
				d0 = d2 = trimPlane.a*v1._x + trimPlane.b*v1._y + trimPlane.c*v1._z + trimPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d0 = d2 = 0;
			
			j = 1;
			i = 0;
			v2 = vertices[0];
			if (uvs) uv2 = uvs[0];
			
			do {
				v1 = v2;
				v2 = vertices[j];
				if (uvs) {
					uv1 = uv2;
					uv2 = uvs[j];
				}
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (trimPlane._alignment == Plane3D.X_AXIS)
						d2 = trimPlane.a*v2._x + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Y_AXIS)
						d2 = trimPlane.b*v2._y + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Z_AXIS)
						d2 = trimPlane.c*v2._z + trimPlane.d;
					else
						d2 = trimPlane.a*v2._x + trimPlane.b*v2._y + trimPlane.c*v2._z + trimPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 <= 0) {
					_newVerts.push(v1);
					if (uvs) _newUVs.push(uv1);
				}
				
				if (d1*d2 < 0)
					trimEdge(trimPlane, v1, v2, uv1, uv2, _newVerts, _newUVs);
				
				if (++j == len) j = 0;
			} while (++i < len);
			
			var vTemp : Vector.<Vertex>;
			var uvTemp : Vector.<UV>;
			
			vTemp = vertices;
			vertices = _newVerts;
			_newVerts = vTemp;
			_newVerts.length = 0;
			
			if (uvs) {
				uvTemp = uvs;
				uvs = _newUVs;
				_newUVs = uvTemp;
				_newUVs.length = 0;
			}
			
//			if (vertices.length >= 3)
//				removeColinears();
		}
		
		/**
		 * Determines if an NGon is too small to be of any use
		 */
		public function isNeglectable() : Boolean
		{
			var i : int = vertices.length;
			var j : int = i-2;
			var v1 : Vertex;
			var v2 : Vertex;
			var dx : Number, dy : Number, dz : Number;
			var count : int;
			var eps : Number = BSPTree.EPSILON*BSPTree.EPSILON;
			
			if (i < 3) return true;
			
			v2 = vertices[i-1];
			
			// check each edge of polygon, must have at least 3 edges long enough
			while (--i >= 0) {
				v1 = v2;
				v2 = vertices[j];
				
				dx = v1._x-v2._x;
				dy = v1._y-v2._y;
				dz = v1._z-v2._z;
				
				if (dx*dx+dy*dy+dz*dz > eps)
					if (++count >= 3) return false;
				
				
				if (--j < 0) j = vertices.length-1;
			}
			
			return true;
		}
		
		/**
		 * Calculates the area of an NGon
		 */
		public function get area() : Number
		{
			var area : Number = 0;
			var v1 : Vertex = vertices[0];
			var v2 : Vertex, v3 : Vertex;
			var len : int = vertices.length-1;
			var ux : Number, uy : Number, uz : Number,
				vx : Number, vy : Number, vz : Number,
				cx : Number, cy : Number, cz : Number;
			var i : int, j : int;
			
			do {
				v2 = vertices[i];
				v3 = vertices[++j];
				ux = v2._x-v1._x;
				uy = v2._y-v1._y;
				uz = v2._z-v1._z;
				vx = v3._x-v1._x;
				vy = v3._y-v1._y;
				vz = v3._z-v1._z;
				
				cx = vy * uz - vz * uy;
        		cy = vz * ux - vx * uz;
        		cz = vx * uy - vy * ux;
				
				area += Math.sqrt(cx*cx+cy*cy+cz*cz);
			} while (++i < len);
			
			return area;
		}
		
		private function trimEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV, newVerts : Vector.<Vertex>, newUV : Vector.<UV>) : void
		{
			var div : Number, t : Number;
			var v : Vertex;
			var uv : UV;
			
			if (plane._alignment == Plane3D.X_AXIS) {
				div = plane.a*(v2._x-v1._x);
				t = -(plane.a*v1._x + plane.d)/div;
			}
			else if (plane._alignment == Plane3D.Y_AXIS) {
				div = plane.b*(v2._y-v1._y);
				t = -(plane.b*v1._y + plane.d)/div;
			}
			else if (plane._alignment == Plane3D.Z_AXIS) {
				div = plane.c*(v2._z-v1._z);
				t = -(plane.c*v1._z + plane.d)/div;
			}
			else {
				div = plane.a*(v2._x-v1._x)+plane.b*(v2._y-v1._y)+plane.c*(v2._z-v1._z);
				t = -(plane.a*v1._x + plane.b*v1._y + plane.c*v1._z + plane.d)/div;
			}
					
			v = new Vertex(v1._x+t*(v2._x-v1._x), v1._y+t*(v2._y-v1._y), v1._z+t*(v2._z-v1._z));
			newVerts.push(v);
			if (uv1 && uv2) {
				uv = new UV(uv1._u+t*(uv2._u-uv1._u), uv1._v+t*(uv2._v-uv1._v));
				newUV.push(uv);
			}
		}
		
		private function splitEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV, pos : NGon, neg : NGon) : void
		{
			var div : Number, t : Number;
			var v : Vertex;
			var uv : UV;
			
			div = plane.a*(v2._x-v1._x)+plane.b*(v2._y-v1._y)+plane.c*(v2._z-v1._z);
			
			t = -(plane.a*v1._x + plane.b*v1._y + plane.c*v1._z + plane.d)/div;
					
			v = new Vertex(v1._x+t*(v2._x-v1._x), v1._y+t*(v2._y-v1._y), v1._z+t*(v2._z-v1._z));
			
			if (pos) pos.vertices.push(v);
			if (neg) neg.vertices.push(v);

			if (uv1 && uv2) {
				uv = new UV(uv1._u+t*(uv2._u-uv1._u), uv1._v+t*(uv2._v-uv1._v));
				if (pos) pos.uvs.push(uv);
				if (neg) neg.uvs.push(uv);
			}
						
		}
		
		private static var _tempU : Number3D = new Number3D();
		private static var _tempV : Number3D = new Number3D();
		private static var _tempC : Number3D = new Number3D();
		
		arcane function removeColinears() : void
		{
			var j : int = 1;
			var k : int = 2;
			var v0 : Vertex, v1 : Vertex, v2 : Vertex;
			var eps : Number = BSPTree.EPSILON*BSPTree.EPSILON;
			var len : int = vertices.length;
			
			for (var i : int = 0; i < len; ++i) {
				v0 = vertices[i];
				v1 = vertices[j];
				v2 = vertices[k];
				
				// check if collinear
				_tempU.x = v1._x-v0._x;
				_tempU.y = v1._y-v0._y;
				_tempU.z = v1._z-v0._z;
				_tempV.x = v2._x-v0._x;
				_tempV.y = v2._y-v0._y;
				_tempV.z = v2._z-v0._z;
				_tempC.cross(_tempU, _tempV);
				
				if (_tempC.modulo2 < eps) {
					vertices.splice(j, 1);
					if (uvs) uvs.splice(j, 1);
					--i;
					--len;
				}
				else {
					++j;
					++k;
				}
				if (j >= len) j = 0;
				if (k >= len) k = 0;
			}
		}
	}
}