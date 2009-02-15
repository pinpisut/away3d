﻿package away3d.extrusions{		import away3d.core.math.Number3D;	import away3d.core.base.*;	import away3d.arcane;	import away3d.materials.*;	import away3d.core.utils.Init;	import away3d.core.math.Matrix3D;	import away3d.animators.data.Path;	import away3d.animators.utils.PathUtils;	import away3d.animators.data.CurveSegment; 	use namespace arcane;		public class PathExtrude extends Mesh	{		private var varr:Array;		private var xAxis:Number3D = new Number3D();    	private var yAxis:Number3D = new Number3D();    	private var zAxis:Number3D = new Number3D();		private var _worldAxis:Number3D = new Number3D(0,1,0);		private var _transform:Matrix3D = new Matrix3D();				private var _path:Path;		private var _points:Array;		private var _scales:Array;		private var _rotations:Array;		private var _subdivision:int = 2;		private var _scaling:Number =  1;		private var _coverall:Boolean = true;		private var _coversegment:Boolean = false;		private var _recenter:Boolean = false;		private var _flip:Boolean = false;		private var _closepath:Boolean = false;		private var _aligntopath:Boolean = true;		private var _smoothscale:Boolean = true;		private var _isClosedProfile:Boolean = false;		private var _doubles:Array = [];		private var _materialList:Array = [];		private var _matIndex:int;		private var _segIndex:int = -1;		private var _segvstart:Number = 0;		private var _segv:Number;		private var _mapfit:Boolean;		        private function orientateAt(target:Number3D, position:Number3D):void        {            zAxis.sub(target, position);            zAxis.normalize();                if (zAxis.modulo > 0.1)            {                xAxis.cross(zAxis, _worldAxis);                xAxis.normalize();                    yAxis.cross(zAxis, xAxis);                yAxis.normalize();                    _transform.sxx = xAxis.x;                _transform.syx = xAxis.y;                _transform.szx = xAxis.z;                    _transform.sxy = -yAxis.x;                _transform.syy = -yAxis.y;                _transform.szy = -yAxis.z;                    _transform.sxz = zAxis.x;                _transform.syz = zAxis.y;                _transform.szz = zAxis.z;            }        }				private function generate(points:Array, offsetV:int = 0, closedata:Boolean = false):void		{				var uvlength:int = (points.length-1) + offsetV;						for(var i:int = 0;i< points.length-1;++i){				varr = new Array();				extrudePoints( points[i], points[i+1], (1/uvlength)*((closedata)? i+(uvlength-1) : i), uvlength, ((closedata)? i+(uvlength-1) : i)/_subdivision);								if(i ==0 && _isClosedProfile){					_doubles = varr.concat();				}			}			varr = null;			_doubles = null;		}						private function extrudePoints(points1:Array, points2:Array, vscale:Number, indexv:int, indexp:int):void		{			var i:int;			var j:int;			var stepx:Number;			var stepy:Number;			var stepz:Number;						var uva:UV;			var uvb:UV;			var uvc:UV;			var uvd:UV;						var va:Vertex;			var vb:Vertex;			var vc:Vertex;			var vd:Vertex;						var u1:Number;			var u2:Number;			var index:int = 0;						var countloop:int = points1.length;						if(_mapfit){				var dist:Number = 0;				var tdist:Number;				var bleft:Number3D;				for(i = 0;i<countloop; ++i){					for(j = 0;j< countloop; ++j){						if(i != j){							tdist = points1[i].distance(points1[j]);							if(tdist>dist){								dist = tdist;								bleft = points1[i];							}						}					}				}				 							} else{				var bu:Number = 0;				var bincu:Number = 1/(countloop-1);			}			var v1:Number = 0;			var v2:Number = 0;						function getDouble(x:Number, y:Number, z:Number ):Vertex			{				for(var i:int = 0;i<_doubles.length; ++i){					if( _doubles[i].x == x && _doubles[i].y == y && _doubles[i].z == z){						return _doubles[i];					}				}				return new Vertex( x, y, z); 			}			 			for( i = 0; i < countloop; ++i){				stepx = points2[i].x - points1[i].x;				stepy = points2[i].y - points1[i].y;				stepz = points2[i].z - points1[i].z;								for( j = 0; j < 2; ++j){					if(_isClosedProfile &&  _doubles.length > 0){						varr.push( getDouble(points1[i].x+(stepx*j) , points1[i].y+(stepy*j), points1[i].z+(stepz*j) )   );					} else {						varr.push( new Vertex( points1[i].x+(stepx*j) , points1[i].y+(stepy*j), points1[i].z+(stepz*j)) );					}				}			}						var mat:ITriangleMaterial;			 			if(_coversegment){								if(indexp>_segIndex){					_segIndex = indexp;					_segvstart = 0;					_segv = 1/(_subdivision);					if(_materialList!= null)						_matIndex = (_matIndex+1 > _materialList.length-1)? 0 : _matIndex+1;				}							} else{								if(_materialList!= null && _coverall== false)						_matIndex = (_matIndex+1 > _materialList.length-1)? 0 : _matIndex+1;			}						mat = (_materialList!= null && _coverall== false)? _materialList[_matIndex] : null;						var k:int;			for( i = 0; i < countloop-1; ++i){								if(_mapfit){					 					u1 = points1[i].distance(bleft)/dist;					u2 = points1[i+1].distance(bleft)/dist;									} else{					u1 = bu;					bu += bincu;					u2 = bu;				}				 				v1 = (_coverall)? vscale : ( (_coversegment)? _segvstart : 0 );				v2 = (_coverall)? vscale+(1/indexv) : ( (_coversegment)? _segvstart+ _segv : 1 );				 				uva = new UV( u1 , v1);				uvb = new UV( u1 , v2 );				uvc = new UV( u2 , v2 );				uvd = new UV( u2 , v1 );				va = varr[index];				vb = varr[index+ 1];				vc = varr[index+3];				vd = varr[index+2];				 				if(flip){					addFace(new Face(vb,va,vc, mat, uvb, uva, uvc ));					addFace(new Face(vc,va,vd, mat, uvc, uva, uvd));									}else{					addFace(new Face(va,vb,vc, mat, uva, uvb, uvc ));					addFace(new Face(va,vc,vd, mat, uva, uvc, uvd));				}				  				if(_mapfit)					u1 = u2;				 				index += 2;			}						if(_coversegment)				_segvstart += _segv;						 		}				/**		 * Creates a new <PathExtrude>PathExtrude</code>		 * 		 * @param	 	path			A Path object. The _path definition.		 * @param	 	points		An array containing a series of Number3D's. Defines the profile to extrude on the _path definition.		 * @param 	scales		[optional]	An array containing a series of Number3D [Number3D(1,1,1)]. Defines the scale per segment. Init object smoothscale true smooth the scale across the segments, set to false the scale is applied equally to the whole segment, default is true.		  * @param 	rotations	[optional]	An array containing a series of Number3D [Number3D(0,0,0)]. Defines the rotation per segment. Default is null. Note that last value entered is reused for the next segment.		 * @param 	init			[optional]	An initialisation object for specifying default instance properties.		 * Init properties are: material, materials, subdivision, scaling, coverall, coversegment, mapfit, recenter, flip, closepath, aligntopath, smoothscale		 */		 		function PathExtrude(path:Path=null, points:Array=null, scales:Array=null, rotations:Array=null, init:Object = null)		{				_path = path;				_points = points;				_scales = scales;				_rotations = rotations;				_materialList = (!init.materials)? null : init.materials;				_matIndex = (!init.materials)? null : _materialList.length;				init = Init.parse(init);				super(init);					_subdivision = init.getInt("subdivision", 1, {min:1});				_scaling = init.getNumber("scaling", 1);				_coverall = init.getBoolean("coverall", true);				_coversegment = init.getBoolean("coversegment", false);				_coverall = (_coversegment)? false : _coverall;				_recenter = init.getBoolean("recenter", false);				_flip = init.getBoolean("flip", false);				_closepath = init.getBoolean("closepath", false);				_aligntopath = init.getBoolean("aligntopath", true);				_smoothscale = init.getBoolean("smoothscale", true);				_mapfit = init.getBoolean("mapfit", false);								if(_points!= null){					_isClosedProfile = (points[0].x == points[points.length-1].x && points[0].y == points[points.length-1].y && points[0].z == points[points.length-1].z);				}				if(_path != null && _points!= null) build();		}				/**    	 * Builds the PathExtrude object.    	 */ 		public function build():void		{			if(_path.length != 0 && _points.length >=2){								_worldAxis = _path.worldAxis;								var aSegPoints:Array = PathUtils.getPointsOnCurve(_path, _subdivision);				var aPointlist:Array = [];				var aSegresult:Array = [];				var atmp:Array;				var tmppt:Number3D = new Number3D(0,0,0);				 				var i:int;				var j:int;				var k:int;								var nextpt:Number3D;								if(_closepath)					var lastP:Array = [];								var rescale:Boolean = (_scales != null);				if(rescale) var lastscale:Number3D = (_scales[0] == null)? new Number3D(1, 1, 1) : _scales[0];									var rotate:Boolean = (_rotations != null);								if(rotate && _rotations.length > 0){					var lastrotate:Number3D = _rotations[0] ;					var nextrotate:Number3D;					var aRotates:Array = [];					var tweenrot:Number3D;				}				 				if(_smoothscale && rescale){					var nextscale:Number3D = new Number3D(1, 1, 1);					var aScales:Array = [lastscale];				}								var tmploop:int = _points.length;				for (i = 0; i <aSegPoints.length; ++i) {					if(rotate){						lastrotate = (_rotations[i] == null) ? lastrotate : _rotations[i];						nextrotate = (_rotations[i+1] == null) ? lastrotate : _rotations[i+1];						aRotates = [lastrotate];						aRotates = aRotates.concat(PathUtils.step( lastrotate, nextrotate,  _subdivision));					}										if(rescale)  lastscale = (_scales[i] == null)? lastscale : _scales[i];					 					if(_smoothscale && rescale ){						nextscale = (_scales[i+1] == null) ? (_scales[i] == null)? lastscale : _scales[i] : _scales[i+1];						aScales = aScales.concat(PathUtils.step( lastscale, nextscale, _subdivision));					}															for(j = 0; j<aSegPoints[i].length;++j){						 						atmp = [];						atmp = atmp.concat(_points);						aPointlist = [];												if(rotate)							tweenrot = aRotates[j];						if(_aligntopath) {							_transform = new Matrix3D();							if(i == aSegPoints.length -1 && j==aSegPoints[i].length-1){																if(_closepath){									nextpt = aSegPoints[0][0];									orientateAt(nextpt, aSegPoints[i][j]);								} else{									nextpt = aSegPoints[i][j-1];									orientateAt(aSegPoints[i][j], nextpt);								}															} else {								nextpt = (j<aSegPoints[i].length-1)? aSegPoints[i][j+1]:  aSegPoints[i+1][0];								orientateAt(nextpt, aSegPoints[i][j]);							}						}												for (k = 0; k <tmploop; ++k) {													if(_aligntopath) {								tmppt = new Number3D();								tmppt.x = atmp[k].x * _transform.sxx + atmp[k].y * _transform.sxy + atmp[k].z * _transform.sxz + _transform.tx;								tmppt.y = atmp[k].x * _transform.syx + atmp[k].y * _transform.syy + atmp[k].z * _transform.syz + _transform.ty;								tmppt.z = atmp[k].x * _transform.szx + atmp[k].y * _transform.szy + atmp[k].z * _transform.szz + _transform.tz;																if(rotate)									tmppt = PathUtils.rotatePoint(tmppt, tweenrot);								 								tmppt.x +=  aSegPoints[i][j].x;								tmppt.y +=  aSegPoints[i][j].y;								tmppt.z +=  aSegPoints[i][j].z;															} else {																tmppt = new Number3D(atmp[k].x+aSegPoints[i][j].x, atmp[k].y+aSegPoints[i][j].y, atmp[k].z+aSegPoints[i][j].z);							}														aPointlist.push(tmppt );														if(rescale && !_smoothscale){									tmppt.x *= lastscale.x;									tmppt.y *= lastscale.y;									tmppt.z *= lastscale.z;							}													}												if (_scaling != 1) {								for (k = 0; k < aPointlist.length; ++k) {									aPointlist[k].x *= _scaling;									aPointlist[k].y *= _scaling;									aPointlist[k].z *= _scaling;								}						}												if(_closepath && i == aSegPoints.length-1 &&  j == aSegPoints[i].length -1) 								break;												if(_closepath)							lastP = aPointlist;														aSegresult.push(aPointlist);						 					}									}				 				if(rescale && _smoothscale){					for (i = 0; i < aScales.length; ++i) {										 for (j = 0;j < aSegresult[i].length; ++j) {							aSegresult[i][j].x *= aScales[i].x;							aSegresult[i][j].y *= aScales[i].y;							aSegresult[i][j].z *= aScales[i].z;						 }					}										aScales = null;				}								if(rotate)					aRotates = null;				 				if(_closepath){					var stepx:Number;					var stepy:Number;					var stepz:Number;					var c:Array;					var c2:Array = [[]];					 					for( i = 1; i < _subdivision+1; ++i){						c = [];						for(j = 0; j < lastP.length; ++j){							stepx = (aSegresult[0][j].x - lastP[j].x)/_subdivision;							stepy = (aSegresult[0][j].y - lastP[j].y)/_subdivision;							stepz = (aSegresult[0][j].z - lastP[j].z)/_subdivision;							c.push( new Number3D( lastP[j].x+(stepx*i) , lastP[j].y+(stepy*i), lastP[j].z+(stepz*i)) );						}						c2.push(c);					}										c2[0] = lastP;					generate(c2, (_coverall)? aSegresult.length : 0, _coverall);					c = c2 = null;				}								generate(aSegresult, (_closepath && _coverall)? 1 : 0, (_closepath && !_coverall));								aSegPoints = null;				varr = null;								if(_recenter)					applyPosition( (this.minX+this.maxX)*.5,  (this.minY+this.maxY)*.5, (this.minZ+this.maxZ)*.5);				 				type = "PathExtrude";				url = "Extrude";						} else {				trace("PathExtrude error: at least 2 Number3D are required in points. Path definition requires at least 1 object with 3 parameters: {v0:Number3D, va:Number3D ,v1:Number3D}, all properties being Number3D.");			} 		}		 		/**    	 * Defines the resolution beetween each CurveSegments. Default 2, minimum 2.    	 */ 		public function set subdivision(val:int):void		{			_subdivision = (val<2)? 2 :val;		}		public function get subdivision():int		{			return _subdivision;		}				/**    	 * Defines the scaling of the final generated mesh. Not being considered while building the mesh. Default 1.    	 */		public function set scaling(val:Number):void		{			_scaling = val;		}		public function get scaling():Number		{			return _scaling;		}				/**    	 * Defines if the texture(s) should cover the entire mesh or per steps between segments. Set coversegment to true to cover per segment. Default true.    	 */		public function set coverall(b:Boolean):void		{			_coverall = b;		}		public function get coverall():Boolean		{			return _coverall;		}				/**    	 * Defines if the texture(s) should applied per segment. Default false.    	 */		public function set coversegment(b:Boolean):void		{			_coversegment = b;		}		public function get coversegment():Boolean		{			return _coversegment;		}				/**    	 * Defines if the texture(s) should be projected on the geometry evenly spreaded over the source bitmapdata or using distance/percent. Default is false.		 * Note that it is NOT suitable if a scale array is being used. The mapping considers first and last profile points are the most distant from each other. most left and most right on the map.    	 */		public function set mapfit(b:Boolean):void		{			_mapfit = b;		}		public function get mapfit():Boolean		{			return _mapfit;		}				/**    	 * Defines if the final mesh should have its pivot reset to its center after generation. Default false.    	 */		public function set recenter(b:Boolean):void		{			_recenter = b;		}		public function get recenter():Boolean		{			return _recenter;		}				/**    	 * Defines if the generated faces should be inversed. Default false.    	 */		public function set flip(b:Boolean):void		{			_flip = b;		}		public function get flip():Boolean		{			return _flip;		}				/**    	 * Defines if the last segment should join the first one and close the loop. Default false.    	 */		public function set closepath(b:Boolean):void		{			_closepath = b;		}		public function get closepath():Boolean		{			return _closepath;		}				/**    	 * Defines if the profile point array should be orientated on path or not. Default true. Note that Path object worldaxis property might need to be changed. default = 0,1,0.    	 */		public function set aligntopath(b:Boolean):void		{			_aligntopath = b;		}		public function get aligntopath():Boolean		{			return _aligntopath;		}				/**    	 * Defines if a scale array of number3d is passed if the scaling should be affecting the whole segment or spreaded from previous curvesegmentscale to the next curvesegmentscale. Default true.    	 */		public function set smoothscale(b:Boolean):void		{			_smoothscale = b;		}		public function get smoothscale():Boolean		{			return _smoothscale;		}				 /**    	 * Sets and defines the Path object. See animators.data package. Required.    	 */ 		 public function set path(p:Path):void    	{    		_path = p;    	}		 public function get path():Path    	{    		return _path;    	}		 		/**    	 * Sets and defines the Array of Number3D's (the profile information to be projected according to the Path object). Required.    	 */		 public function set points(aR:Array):void    	{    		_points = aR;			_isClosedProfile = (points[0].x == points[points.length-1].x && points[0].y == points[points.length-1].y && points[0].z == points[points.length-1].z);    	}		 public function get points():Array    	{    		return _points;    	}		 		/**    	 * Sets and defines the optional Array of Number3D's. A series of scales to be set on each CurveSegments    	 */		 public function set scales(aR:Array):void    	{    		_scales = aR;    	}		 public function get scales():Array    	{    		return _scales;    	}				/**    	 * Sets and defines the optional Array of Number3D's. A series of rotations to be set on each CurveSegments    	 */		 public function set rotations(aR:Array):void    	{    		_rotations = aR;    	}		 public function get rotations():Array    	{    		return _rotations;    	}				/**    	 * Sets an optional Array of materials. The materials are applyed after each other when coverall is false. On each repeats if coversegment is false.		 * Once the last material in array is reached while path is not finished yet, the material at index 0 will be used again, then 1, 2 etc... until the construction reaches the end of the path definition.    	 */		 public function set materials(aR:Array):void    	{    		_materialList = aR;    	}		 public function get materials():Array    	{    		return _materialList;    	}	}}