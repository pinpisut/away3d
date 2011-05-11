﻿package away3d.tools{	import away3d.arcane;	import away3d.core.base.Geometry;	import away3d.core.base.SubMesh;	import away3d.core.base.data.Vertex;	import away3d.core.base.SubGeometry;	import away3d.entities.Mesh;	import away3d.containers.ObjectContainer3D;	import away3d.materials.MaterialBase;		import flash.geom.Matrix3D;	import flash.geom.Vector3D;	use namespace arcane;	/**	*  Class Merge merges two or more meshes into one.<code>Merge</code>	*  Doesn't support Animation Merging (yet)	*/	public class Merge{				private const LIMIT:uint = 64998;		private var _m1:Mesh;		private var _objectspace:Boolean;		private var _keepMaterial:Boolean;		private var _disposeSources:Boolean;		private var _holder:Vector3D;		   		/**		* @param	 objectspace		[optional] Boolean. Defines if mesh2 is merge using its objectspace or worldspace. Default is false.		* @param	 keepMaterial		[optional] Boolean. Defines if the merged object uses the mesh1 material information or keeps its material(s). Default is false.		* If set to false and receiver object has multiple materials, the last material found in mesh1 submeshes is applied to mesh2 submeshes. 		* @param	 disposeSources	[optional] Boolean. Defines if mesh2 (or sources meshes in case applyToContainer is used) are kept untouched or disposed. Default is false.		* If keepMaterial is true, only geometry and eventual ObjectContainers3D are cleared from memory.		*/				function Merge(objectspace:Boolean = false, keepMaterial:Boolean = false, disposeSources:Boolean = false):void		{			_objectspace = objectspace;			_keepMaterial = keepMaterial;			_disposeSources = disposeSources;		}				/**		* Defines if the mesh(es) sources used for the merging are kept or disposed.		*/		public function set disposeSources(b:Boolean):void		{			_disposeSources = b;		}				public function get disposeSources():Boolean		{			return _disposeSources;		}		/**		* Defines if mesh2 will be merged using its own material information.		*/		public function set keepmaterial(b:Boolean):void		{			_keepMaterial = b;		}				public function get keepMaterial():Boolean		{			return _keepMaterial;		}				/**		* Defines if mesh2 is merged using its objectspace.		*/		public function set objectspace(b:Boolean):void		{			_objectspace = b;		}				public function get objectspace():Boolean		{			return _objectspace;		}				/**		*  Merges all the children of a container as one single Mesh.		* 	The first Mesh child encountered becomes the receiver. This is mesh that is returned.		* 	If no Mesh object is found, class returns null.		* @param	 objectContainer		*		* @return The merged Mesh instance		*/		public function applyToContainer(object:ObjectContainer3D):Mesh		{			_m1 = null;			parseContainer(object);						if(_disposeSources)				object = null;						return _m1;		}		 		/**		*  Merge 2 meshes into one		* @param	 mesh1				Mesh. The receiver object that will hold both meshes information.		* @param	 mesh2				Mesh. The Mesh object to be merge with mesh1.		*/		public function apply(mesh1:Mesh, mesh2:Mesh):void		{			var j : uint;			var i : uint;			var vecLength : uint;			var subGeom : SubGeometry;						var scenePosX:Number = 0.0;			var scenePosY:Number = 0.0;			var scenePosZ:Number = 0.0;						if(!_objectspace){								var v:Vertex = new Vertex();				var vn:Vertex = new Vertex();				var t:Matrix3D = mesh2.transform;								scenePosX = mesh2.x - mesh1.x;				scenePosY = mesh2.y - mesh1.y;				scenePosZ = mesh2.z - mesh1.z;			}						var geometry:Geometry = mesh1.geometry;			var geometries:Vector.<SubGeometry> = geometry.subGeometries;			var numSubGeoms:int = geometries.length;						var vertices:Vector.<Number>;			var normals:Vector.<Number>;			var indices:Vector.<uint>;			var uvs:Vector.<Number>;			var vectors:Vector.<DataSubGeometry> = new Vector.<DataSubGeometry>();			var vectorsSource:Vector.<DataSubGeometry> = new Vector.<DataSubGeometry>();			var ds:DataSubGeometry;						for (i = 0; i<numSubGeoms; ++i){					 				vertices = SubGeometry(geometries[i]).vertexData;				normals = SubGeometry(geometries[i]).vertexNormalData;				indices = SubGeometry(geometries[i]).indexData;				uvs = SubGeometry(geometries[i]).UVData;								vertices.fixed = false;				normals.fixed = false;				indices.fixed = false;				uvs.fixed = false;								ds = new DataSubGeometry();				ds.vertices = vertices;				ds.indices = indices;				ds.uvs = uvs;				ds.normals = normals;				ds.subMesh = SubMesh(mesh1.subMeshes[i]);				ds.material = (ds.subMesh.material)? ds.subMesh.material : mesh1.material; 				ds.subGeometry = SubGeometry(geometries[i]);				vectors.push(ds);			}						var nvertices:Vector.<Number>;			var nindices:Vector.<uint>;			var nuvs:Vector.<Number>;			var nnormals:Vector.<Number>;			var nIndex:uint;			var nIndexind:uint;			var nIndexuv:uint;			nvertices = ds.vertices;			nindices = ds.indices;			nuvs = ds.uvs;			nnormals = ds.normals;						nIndex = nvertices.length;			nIndexind = nindices.length;			nIndexuv = nuvs.length;				 			var activeMaterial:MaterialBase = ds.material;						var geometry2:Geometry = mesh2.geometry;			var geometriesM2:Vector.<SubGeometry> = geometry2.subGeometries;			numSubGeoms = geometriesM2.length;						for (i = 0; i<numSubGeoms; ++i){					 				ds = new DataSubGeometry();				ds.vertices = SubGeometry(geometriesM2[i]).vertexData;				ds.indices = SubGeometry(geometriesM2[i]).indexData;				ds.uvs = SubGeometry(geometriesM2[i]).UVData;				ds.normals = SubGeometry(geometriesM2[i]).vertexNormalData;								ds.vertices.fixed = false;				ds.normals.fixed = false;				ds.indices.fixed = false;				ds.uvs.fixed = false;								ds.subMesh = SubMesh(mesh2.subMeshes[i]);				ds.material = (ds.subMesh.material)? ds.subMesh.material : mesh2.material; 				ds.subGeometry = SubGeometry(geometriesM2[i]);				vectorsSource.push(ds);			}			 			var index:uint;			var indexY:uint;			var indexZ:uint;						var indexuv:uint;			var indexind:uint;			var destDs:DataSubGeometry;			var rotate:Boolean = (mesh2.rotationX != 0 || mesh2.rotationY != 0 || mesh2.rotationZ != 0);			 			for (i = 0; i < numSubGeoms; ++i){				ds = vectorsSource[i];				subGeom = ds.subGeometry;				vertices = ds.vertices;				normals = ds.normals;				indices = ds.indices;				uvs = ds.uvs;				  				if(_keepMaterial){					destDs = getDestSubgeom(vectors, ds);					if(!destDs){						destDs = vectorsSource[i];						subGeom = new SubGeometry();						geometry.addSubGeometry(subGeom);						destDs.subMesh = SubMesh(mesh1.subMeshes[vectors.length]);						destDs.subGeometry = subGeom;												if(!_objectspace){						 	vecLength = destDs.vertices.length;											for (j = 0; j < vecLength;j+=3){								indexY = j+1;								indexZ = indexY+1;								v.x = destDs.vertices[j];								v.y = destDs.vertices[indexY];								v.z = destDs.vertices[indexZ];								 								if(rotate) {									vn.x = destDs.normals[j];									vn.y = destDs.normals[indexY];									vn.z = destDs.normals[indexZ];									v = applyRotations(v, t);									vn = applyRotations(vn, t);									destDs.normals[j] = vn.x;									destDs.normals[indexY] = vn.y;									destDs.normals[indexZ] = vn.z;								}																v.x += scenePosX;								v.y += scenePosY;								v.z += scenePosZ;																destDs.vertices[j] = v.x;								destDs.vertices[indexY] = v.y;								destDs.vertices[indexZ] = v.z;							}						}						vectors.push(destDs);						continue;					}										activeMaterial = destDs.material;					nvertices = destDs.vertices;					nnormals = destDs.normals;					nindices = destDs.indices;					nuvs = destDs.uvs;					nIndex = nvertices.length;					nIndexind = nindices.length;					nIndexuv = nuvs.length;				}				vecLength = indices.length;								for (j = 0; j < vecLength;++j){					 					if(nvertices.length+3 > LIMIT){						ds = new DataSubGeometry();						nIndexind = 0;						nIndex = 0;						nIndexuv = 0;												nvertices = ds.vertices = new Vector.<Number>();						nnormals = ds.normals = new Vector.<Number>();						nindices = ds.indices = new Vector.<uint>();						nuvs = ds.uvs = new Vector.<Number>();						subGeom = new SubGeometry();						geometry.addSubGeometry(subGeom);						ds.subMesh = SubMesh(mesh1.subMeshes[vectors.length]);						ds.material = activeMaterial; 						ds.subGeometry = subGeom;												vectors.push(ds);					}										index = indices[j]*3;					indexuv = indices[j]*2;					nindices[nIndexind++] = nvertices.length/3;										indexY = index+1;					indexZ = indexY+1;										if(_objectspace){												nvertices[nIndex++] = vertices[index];						nvertices[nIndex++] = vertices[indexY];						nvertices[nIndex++] = vertices[index+2];						 					} else {												v.x = vertices[index];						v.y = vertices[indexY];						v.z = vertices[indexZ];												if(rotate) {							vn.x = normals[index];							vn.y = normals[indexY];							vn.z = normals[indexZ];							v = applyRotations(v, t);							vn = applyRotations(vn, t);							nnormals.push(vn.x, vn.y, vn.z);						}												v.x += scenePosX;						v.y += scenePosY;						v.z += scenePosZ;												nvertices[nIndex++] = v.x;						nvertices[nIndex++] = v.y;						nvertices[nIndex++] = v.z;					}										if(_objectspace || !rotate)						nnormals.push(normals[index], normals[indexY], normals[indexZ]);										nuvs[nIndexuv++] = uvs[indexuv];					nuvs[nIndexuv++] = uvs[indexuv+1];				} 			} 						for (i = 0; i < vectors.length; ++i){				ds = vectors[i];				subGeom = ds.subGeometry;				subGeom.autoDeriveVertexNormals = false;				subGeom.autoDeriveVertexTangents = true;				subGeom.updateVertexData(ds.vertices);				subGeom.updateIndexData(ds.indices);				subGeom.updateUVData(ds.uvs);				subGeom.updateVertexNormalData(ds.normals);				ds.subMesh.material = ds.material;			}			 			vectors = vectorsSource = null;						if(_disposeSources){				if(_keepMaterial)					mesh2.geometry.dispose();				else					mesh2.dispose(true);				mesh2 = null;			}						if(!_objectspace)				v = vn = null;		}				private function getDestSubgeom(v:Vector.<DataSubGeometry>, ds:DataSubGeometry):DataSubGeometry		{			var targetDs:DataSubGeometry;			var len:uint = v.length-1;			for (var i:int = len; i>-1; --i){				if(v[i].material == ds.material){					targetDs = v[i];					return targetDs;				}			}						return null;		}				private function parseContainer(object:ObjectContainer3D):void		{			var child:ObjectContainer3D;						if(object is Mesh && object.numChildren == 0){				if(!_m1){					_m1 = Mesh(object);				} else {					apply(_m1, Mesh(object));				}			}			 			for(var i:uint = 0;i<object.numChildren;++i){				child = object.getChildAt(i);				if(child!=_m1)					parseContainer(child);			}		}				private function applyRotations(v:Vertex, t:Matrix3D):Vertex		{			if(_holder == null)				_holder = new Vector3D();						_holder.x = v.x;			_holder.y = v.y;			_holder.z = v.z;						_holder = t.deltaTransformVector(_holder);						v.x = _holder.x;			v.y = _holder.y;			v.z = _holder.z;						return v;		}		 	}}class DataSubGeometry {	import away3d.core.base.SubGeometry;	import away3d.core.base.SubMesh;	import away3d.materials.MaterialBase;		public var uvs:Vector.<Number>;	public var vertices:Vector.<Number>;	public var normals:Vector.<Number>;	public var indices:Vector.<uint>;	public var subGeometry:SubGeometry;	public var material:MaterialBase;	public var subMesh:SubMesh;}