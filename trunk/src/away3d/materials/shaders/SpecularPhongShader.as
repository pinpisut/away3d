﻿package away3d.materials.shaders{	import away3d.containers.*;	import away3d.core.*;	import away3d.core.base.*;	import away3d.core.draw.*;	import away3d.core.math.*;	import away3d.core.render.*;	import away3d.core.utils.*;	import away3d.materials.*;		import flash.display.*;	import flash.geom.*;	import flash.utils.*;	    public class SpecularPhongShader extends AbstractShader    {		use namespace arcane;				internal var _shininess:Number;		internal var _specular:Number;				internal var _specMin:Number;		internal var _specColor:ColorTransform;                public function set shininess(val:Number):void        {        	_shininess = val;        	_specMin = Math.pow(0.8, _shininess/20);        }                public function get shininess():Number        {        	return _shininess;        }				public function set specular(val:Number):void		{			_specular = val;            _specColor = new ColorTransform(1, 1, 1, _specular, 0, 0, 0, 0);		}				public function get specular():Number		{			return _specular;		}		        public function SpecularPhongShader(init:Object = null)        {        	super(init);            init = Init.parse(init);            shininess = init.getNumber("shininess", 20);            specular = init.getNumber("specular", 1);        }				public override function updateMaterial(source:Object3D, view:View3D):void        {        	clearLightingShapeDictionary();        	        	for each (directional in source.session.lightarray.directionals) {        		if (!directional.specularTransform[source])        			directional.specularTransform[source] = new Dictionary(true);        		if (!directional.specularTransform[source][view] || source.sceneTransformed || source.session.view.camera.sceneTransformed) {        			directional.setSpecularTransform(source, view);        			clearFaceDictionary(source, view);        		}        	}        }                public override function clearFaceDictionary(source:Object3D, view:View3D):void        {        	for each (_faceVO in _faceDictionary) {        		if (source == _faceVO.source && view == _faceVO.view) {	        		if (!_faceVO.cleared)	        			_faceVO.clear();	        		_faceVO.invalidated = true;	        	}        	}        }		        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void        {        	super.renderLayer(tri, layer, level);        	        	for each (directional in _lights.directionals)        	{	        					_specularTransform = directional.specularTransform[_source][_view];        		        		_n0 = _source.getVertexNormal(tri.face.v0);				_n1 = _source.getVertexNormal(tri.face.v1);				_n2 = _source.getVertexNormal(tri.face.v2);								_nFace = tri.face.normal;								_szx = _specularTransform.szx;				_szy = _specularTransform.szy;				_szz = _specularTransform.szz;								specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess/20);				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess/20);				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess/20);				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess/20);								if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {						        		_shape = getLightingShape(layer, directional);		        			        	_shape.blendMode = blendMode;		        			        	_shape.alpha = _specular;		        	_graphics = _shape.graphics;		        						_sxx = _specularTransform.sxx;					_sxy = _specularTransform.sxy;					_sxz = _specularTransform.sxz;										_syx = _specularTransform.syx;					_syy = _specularTransform.syy;					_syz = _specularTransform.syz;										eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;					eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;					eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;					eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;					eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;					eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;										coeff1 = 255*Math.acos(specVal1)/Math.sqrt(eTri0x*eTri0x + eTri0y*eTri0y);					coeff2 = 255*Math.acos(specVal2)/Math.sqrt(eTri1x*eTri1x + eTri1y*eTri1y);					coeff3 = 255*Math.acos(specVal3)/Math.sqrt(eTri2x*eTri2x + eTri2y*eTri2y);										eTri0x *= coeff1;					eTri0y *= coeff1;					eTri1x *= coeff2;					eTri1y *= coeff2;					eTri2x *= coeff3;					eTri2y *= coeff3;										//calulate mapping					_mapping.a = (eTri1x - eTri0x);					_mapping.b = (eTri1y - eTri0y);					_mapping.c = (eTri2x - eTri0x);					_mapping.d = (eTri2y - eTri0y);					_mapping.tx = eTri0x + 255;					_mapping.ty = eTri0y + 255;		            _mapping.invert();	            					_source.session.renderTriangleBitmap(directional.specularBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);				}        	}						if (debug)                _source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);        }				internal var _specularTransform:Matrix3D;		internal var _nFace:Number3D;		internal var _nFaceTransZ:Number;				internal var specVal1:Number;		internal var specVal2:Number;		internal var specVal3:Number;		internal var specValFace:Number;				internal var coeff1:Number;		internal var coeff2:Number;		internal var coeff3:Number;				internal var _sxx:Number;     internal var _sxy:Number;     internal var _sxz:Number;        internal var _syx:Number;     internal var _syy:Number;     internal var _syz:Number;        internal var _szx:Number;     internal var _szy:Number;     internal var _szz:Number;                public override function renderShader(face:Face):void        {						for each (directional in _source.session.lightarray.directionals)        	{        		_specularTransform = directional.specularTransform[_source][_view];        		        		_n0 = _source.getVertexNormal(face.v0);				_n1 = _source.getVertexNormal(face.v1);				_n2 = _source.getVertexNormal(face.v2);								_nFace = face.normal;								_szx = _specularTransform.szx;				_szy = _specularTransform.szy;				_szz = _specularTransform.szz;								specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess/20);				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess/20);				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess/20);				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess/20);								if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {										//store a clone					if (_faceVO.cleared && !_parentFaceVO.updated) {						_faceVO.bitmap = _parentFaceVO.bitmap.clone();						_faceVO.bitmap.lock();					}										_faceVO.cleared = false;					_faceVO.updated = true;										_sxx = _specularTransform.sxx;					_sxy = _specularTransform.sxy;					_sxz = _specularTransform.sxz;										_syx = _specularTransform.syx;					_syy = _specularTransform.syy;					_syz = _specularTransform.syz;										eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;					eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;					eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;					eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;					eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;					eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;										coeff1 = 255*Math.acos(specVal1)/Math.sqrt(eTri0x*eTri0x + eTri0y*eTri0y);					coeff2 = 255*Math.acos(specVal2)/Math.sqrt(eTri1x*eTri1x + eTri1y*eTri1y);					coeff3 = 255*Math.acos(specVal3)/Math.sqrt(eTri2x*eTri2x + eTri2y*eTri2y);										eTri0x *= coeff1;					eTri0y *= coeff1;					eTri1x *= coeff2;					eTri1y *= coeff2;					eTri2x *= coeff3;					eTri2y *= coeff3;										//calulate mapping					_mapping.a = (eTri1x - eTri0x);					_mapping.b = (eTri1y - eTri0y);					_mapping.c = (eTri2x - eTri0x);					_mapping.d = (eTri2y - eTri0y);					_mapping.tx = eTri0x + 255;					_mapping.ty = eTri0y + 255;		            _mapping.invert();		            _mapping.concat(face._dt.invtexturemapping);		            					//draw into faceBitmap					_graphics = _s.graphics;					_graphics.clear();					_graphics.beginBitmapFill(directional.specularBitmap, _mapping, false, smooth);					_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);		            _graphics.endFill();					_faceVO.bitmap.draw(_s, null, _specColor, blendMode);					//_faceVO.bitmap.draw(directional.specularBitmap, _mapping, _specColor, blendMode, _faceVO.bitmap.rect, smooth);				}        	}        }    }}