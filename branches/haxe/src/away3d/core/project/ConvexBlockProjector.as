package away3d.core.project
{
	import away3d.blockers.*;
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class ConvexBlockProjector implements IBlockerProvider, IPrimitiveProvider
	{
		private var _view:View3D;
		private var _vertexDictionary:Dictionary;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _convexBlock:ConvexBlock;
		private var _camera:Camera3D;
		private var _lens:ILens;
		private var _vertices:Array;
		private var _displayObject:DisplayObject;
		private var _segmentMaterial:ISegmentMaterial;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
        private var _points:Array;
        private var _base:ScreenVertex;
        private var _s:String;
        private var _p:String;
        
        private function cross(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex):Number
        {
            return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y);
        }
        
        public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	_view = val;
        	_drawPrimitiveStore = _view.drawPrimitiveStore;
        }
        
		/**
		 * @inheritDoc
		 * 
    	 * @see	away3d.core.traverse.BlockerTraverser
    	 * @see	away3d.core.block.Blocker
		 */
        public function blockers(source:Object3D, viewTransform:Matrix3D, consumer:IBlockerConsumer):void
        {
			_vertexDictionary = _drawPrimitiveStore.createVertexDictionary(source);
			
        	_convexBlock = source as ConvexBlock;
			
			_camera = _view.camera;
			_lens = _camera.lens;
			
			_vertices = _convexBlock.vertices;
            
        	if (_vertices.length < 3)
                return;
			
			_points = [];
			_base = null;
			_s = "";
			_p = "";
			
            for each (_vertex in _vertices)
            {
                _s += _vertex.toString() + "\n";
                
				_screenVertex = _lens.project(viewTransform, _vertex);
				
                if (_base == null)
                    _base = _screenVertex;
                else
                if (_base.y > _screenVertex.y)
                    _base = _screenVertex;
                else
                if (_base.y == _screenVertex.y)
                    if (_base.x > _screenVertex.x)
                        _base = _screenVertex;
				
                _points.push(_screenVertex);
                _p += _screenVertex.toString() + "\n";
            }
			
//            throw new Error(s + p);
			
            for each (_screenVertex in _points)
                _screenVertex.num = (_screenVertex.x - _base.x) / (_screenVertex.y - _base.y);
            
            _base.num = -Infinity;

            _points.sortOn("num", Array.NUMERIC);
            
            var result:Array = [_points[0], _points[1]];
            var o:Number;

            for (var i:int = 2; i < _points.length; i++)
            {
                o = cross(result[result.length-2], result[result.length-1], _points[i]);
                while (o > 0)
                {
                    result.pop();
                    if (result.length == 2)
                        break;
                    o = cross(result[result.length-2], result[result.length-1], _points[i]);
                }
                result.push(_points[i]);
            }
            o = cross(result[result.length-2], result[result.length-1], result[0]);
            if (o > 0)
                result.pop();
			
            consumer.blocker(_drawPrimitiveStore.createConvexBlocker(source, result));
 		}
 		
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			_convexBlock = source as ConvexBlock;
			
        	if (_convexBlock.debug)
                consumer.primitive(_drawPrimitiveStore.blockerDictionary[source]);
		}
	}
}