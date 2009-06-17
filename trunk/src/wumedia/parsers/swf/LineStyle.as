/* * Copyright 2009 (c) Guojian Miguel Wu, guojian@wu-media.com | guojian.wu@ogilvy.com * * Permission is hereby granted, free of charge, to any person * obtaining a copy of this software and associated documentation * files (the "Software"), to deal in the Software without * restriction, including without limitation the rights to use, * copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the * Software is furnished to do so, subject to the following * conditions: * * The above copyright notice and this permission notice shall be * included in all copies or substantial portions of the Software. * * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR * OTHER DEALINGS IN THE SOFTWARE. */package wumedia.parsers.swf {	import flash.display.CapsStyle;	import flash.display.JointStyle;			/**	 * @author guojianwu	 */	public class LineStyle {		static public const TYPE_1	:uint = 0;		static public const TYPE_2 :uint = 1;		public function LineStyle(type:uint, data:Data, hasAlpha:Boolean = true) {			this.type = type;			if ( data ) {				if (type == TYPE_1) {					parseStyle1(data, hasAlpha);				} else {					parseStyle2(data, hasAlpha);				}			}		}		private var _flags		:uint;		public var type			:uint;		public var width		:Number;		public var color		:Color;		public var startCaps	:String;		public var endCaps		:String;		public var jointStyle	:String;		public var noClose		:Boolean;		public var miterLimit	:Number;				public function apply(graphics:*):void {			if ( graphics["hasOwnProperty"]("lineStyle") ) {				if ( color ) {					graphics["lineStyle"](width, color.color, color.alpha);				} else {					graphics["lineStyle"]();				}			}		}				private function parseStyle1(data:Data, hasAlpha:Boolean = true):void {			width = data.readUnsignedShort() * 0.05;			color = new Color(data, hasAlpha);		}				private function parseStyle2(data:Data, hasAlpha:Boolean = true):void {			var tmp:uint;			width = data.readUnsignedShort() * 0.05;						tmp = data.readUBits(2);			if ( tmp == 0 ) {				startCaps = CapsStyle.ROUND;			} else if ( tmp == 1 ) {				startCaps = CapsStyle.NONE;			} else {				startCaps = CapsStyle.SQUARE;			}			tmp = data.readUBits(2);			if ( tmp == 0 ) {				jointStyle = JointStyle.ROUND;			} else if ( tmp == 1 ) {				jointStyle = JointStyle.BEVEL;			} else {				jointStyle = JointStyle.MITER;			}			_flags = data.readUBits(4);			data.readUBits(5); // reversed, always 0			noClose = data.readUBits(1) == 1;			tmp = data.readUBits(2);			if ( tmp == 0 ) {				endCaps = CapsStyle.ROUND;			} else if ( tmp == 1 ) {				endCaps = CapsStyle.NONE;			} else {				endCaps = CapsStyle.SQUARE;			}			if ( jointStyle == JointStyle.MITER ) {				miterLimit = data.readUnsignedShort() * 0.05;			}			if ( hasFill ) {				// TODO - finish fill style for lines							} else {				color = new Color(data, hasAlpha);			}		}				public function get hasFill():Boolean { return (_flags & 0x08) != 0; }		public function get noHScale():Boolean { return (_flags & 0x04) != 0; }		public function get noVScale():Boolean { return (_flags & 0x02) != 0; }		public function get pixelHinting():Boolean { return (_flags & 0x01) != 0; }	}}