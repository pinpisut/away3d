﻿package away3d.entities{	import away3d.animators.data.AnimationBase;	import away3d.animators.data.AnimationStateBase;	import away3d.animators.data.NullAnimation;	import away3d.arcane;	import away3d.bounds.BoundingSphere;	import away3d.bounds.BoundingVolumeBase;	import away3d.core.base.IRenderable;	import away3d.core.partition.EntityNode;	import away3d.core.partition.RenderableNode;	import away3d.materials.MaterialBase;	import away3d.materials.WireframeMaterial;	import away3d.primitives.SegmentBase;	import away3d.containers.View3D;	import flash.display3D.Context3D;	import flash.display3D.IndexBuffer3D;	import flash.display3D.VertexBuffer3D;		import flash.geom.Vector3D; 	use namespace arcane;	 	public class SegmentsBase extends Entity implements IRenderable {				private var _material : MaterialBase;		private var _nullAnimation : NullAnimation;		private var _animationState : AnimationStateBase;		private var _vertices : Vector.<Number>;		private var _segments : Vector.<SegmentBase>;				private var _numVertices : Number;		private var _indices : Vector.<uint>;		private var _numIndices : uint;		private var _vertexBufferDirty : Boolean= true;		private var _indexBufferDirty : Boolean= true;		private var _vertexBuffer : VertexBuffer3D;		private var _indexBuffer : IndexBuffer3D;		 		public function SegmentsBase(view:View3D)		{			super();					_nullAnimation ||= new NullAnimation();			_vertices = new Vector.<Number>();			_segments = new Vector.<SegmentBase>();			_numVertices =0;			_indices = new Vector.<uint>();			_numIndices=0;						this.material = new WireframeMaterial(view.width, view.height);		}		 		public function addSegment(segment : SegmentBase):void		{			var t:Number = segment.thickness;			var colors:Vector.<Number> = segment.rgbColorVector;			var verts:Vector.<Number> = segment.vertices;						// to do add CurveSegment/LineSegment check			// for now, support only LineSegment			 			var index:uint = _vertices.length;			_vertices.push(	verts[0], verts[1], verts[2], verts[3], verts[4], verts[5], t, colors[0], colors[1], colors[2], 1,									verts[3], verts[4], verts[5],	verts[0], verts[1], verts[2],	-t, colors[3], colors[4], colors[5], 1,									verts[0], verts[1], verts[2],	verts[3], verts[4], verts[5],	-t, colors[0], colors[1], colors[2], 1,									verts[3], verts[4], verts[5],	verts[0], verts[1], verts[2],	 t,	colors[3], colors[4], colors[5], 1);			 			_segments.push(segment);			segment.segmentsBase = this;			 			segment.index = _indices.length;			_indices.push(index, index+1, index+2, index+3, index+2, index+1);									_numVertices = _vertices.length/11;			_numIndices = _indices.length;			_vertexBufferDirty = true;			_indexBufferDirty = true;		}				arcane function updateSegment(segment : SegmentBase):void		{			//to do add support for curve segment			var verts:Vector.<Number> = segment.vertices;			var colors:Vector.<Number> = segment.rgbColorVector;			var index:uint = segment.index;			var t:Number = segment.thickness;						_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = t;			_vertices[index++] = colors[0];			_vertices[index++] = colors[1];			_vertices[index++] = colors[2];			_vertices[index++] = 1;			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = -t;			_vertices[index++] = colors[3];			_vertices[index++] = colors[4];			_vertices[index++] = colors[5];			_vertices[index++] = 1;			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = -t;			_vertices[index++] = colors[0];			_vertices[index++] = colors[1];			_vertices[index++] = colors[2];			_vertices[index++] = 1;			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = t;			_vertices[index++] = colors[3];			_vertices[index++] = colors[4];			_vertices[index++] = colors[5];			_vertices[index++] = 1;						_vertexBufferDirty = true;		}		 		private function remove(index:uint):void		{			var indVert:uint = _indices[index]*11;			_indices.splice(index, 6);			_vertices.splice(indVert, 44);						_numVertices = _vertices.length/11;			_numIndices = _indices.length;			_vertexBufferDirty = true;			_indexBufferDirty = true;			 		}				public function removeSegment(segment : SegmentBase):void		{			//to do, check indices indice reset other segments, support curve indices			var index:uint;			for(var i:uint = 0;i<_segments.length;++i){				if(_segments[i] == segment){					_segments.splice(i, 1);					remove(segment.index);					_vertexBufferDirty = true;					_indexBufferDirty = true;				} else {					_segments[i].index = index;					index+=6;				}			}		}		public function getVertexBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			if (_vertexBufferDirty ) {				_vertexBuffer= context.createVertexBuffer(_numVertices, 11);				_vertexBuffer.uploadFromVector(_vertices, 0, _numVertices);				_vertexBufferDirty = false;			}			return _vertexBuffer;		}		public function getUVBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getVertexNormalBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getVertexTangentBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getIndexBuffer(context : Context3D, contextIndex : uint) : IndexBuffer3D		{			if (_indexBufferDirty ) {				_indexBuffer= context.createIndexBuffer(_numIndices);				_indexBuffer.uploadFromVector(_indices, 0, _numIndices);				_indexBufferDirty = false;			}				return _indexBuffer;		}				public function get mouseDetails() : Boolean {			// TODO: Auto-generated method stub			return false;		}				public function get numTriangles() : uint {			// TODO: Auto-generated method stub			return _numIndices/3;		}				public function get sourceEntity() : Entity {			// TODO: Auto-generated method stub			return this;		}				public function get shadowCaster() : Boolean {			// TODO: Auto-generated method stub			return false;		}				public function get material() : MaterialBase {				return _material;		}				public function get animation() : AnimationBase {			// TODO: Auto-generated method stub			return _nullAnimation;		}				public function get animationState() : AnimationStateBase {			// TODO: Auto-generated method stub			return _animationState;		}				public function set material(value : MaterialBase) : void {			if (value == _material) return;			if (_material) _material.removeOwner(this);			_material = value;			if (_material) _material.addOwner(this);		}			override protected function getDefaultBoundingVolume() : BoundingVolumeBase		{			return new BoundingSphere();		}		override protected function updateBounds() : void		{			_bounds.fromExtremes(-100, -100, 0, 100, 100, 0);			_boundsInvalid = false;		}		override protected function createEntityPartitionNode() : EntityNode		{			return new RenderableNode(this);		}	}}