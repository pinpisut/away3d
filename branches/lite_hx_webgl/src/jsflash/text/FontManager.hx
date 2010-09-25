package jsflash.text;

import jsflash.text.FontInstance;
import jsflash.text.Font;
import jsflash.swf.ScaledFont;
import flash.geom.Matrix;

class FontManager
{
   static var mFontMap = new Hash<jsflash.text.Font>();
   static var mSWFFonts = new Hash<jsflash.swf.Font>();
   
   static public function GetFont(inFace:String,inHeight:Int) : Font
   {
      var id = inFace+":"+inHeight;
      var font:Font = mFontMap.get(inFace);
      if (font==null)
      {
         // Look for swf font ...
         var swf_font = mSWFFonts.get(inFace);
         if (swf_font!=null)
         {
            font = new ScaledFont(swf_font,inHeight);
         }
         else
         {
            var native_font = new NativeFont(inFace,inHeight);
            if (native_font.Ok())
               font = native_font;
         }

         if (font!=null)
           mFontMap.set(id,font);
      }

      return font;
   }

   static public function RegisterFont(inFont:jsflash.swf.Font)
   {
      // trace("Register :" + inFont.GetName() + "<");
      mSWFFonts.set(inFont.GetName(), inFont);
   }

}