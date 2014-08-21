package fl.controls.progressBarClasses
{
   import fl.core.UIComponent;
   import flash.display.Sprite;
   import flash.display.BitmapData;
   import flash.events.Event;
   import fl.core.InvalidationType;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   
   public class IndeterminateBar extends UIComponent
   {
      
      public function IndeterminateBar()
      {
         super();
         setSize(0,0);
         startAnimation();
      }
      
      private static var defaultStyles:Object = {"indeterminateSkin":"ProgressBar_indeterminateSkin"};
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      protected var animationCount:uint = 0;
      
      protected var bar:Sprite;
      
      protected var barMask:Sprite;
      
      protected var patternBmp:BitmapData;
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            startAnimation();
         }
         else
         {
            stopAnimation();
         }
         super.visible = param1;
      }
      
      protected function startAnimation() : void
      {
         addEventListener(Event.ENTER_FRAME,handleEnterFrame,false,0,true);
      }
      
      protected function stopAnimation() : void
      {
         removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
      }
      
      protected function handleEnterFrame(param1:Event) : void
      {
         if(patternBmp == null)
         {
            return;
         }
         animationCount = (animationCount + 2) % patternBmp.width;
         bar.x = -animationCount;
      }
      
      override protected function configUI() : void
      {
         bar = new Sprite();
         addChild(bar);
         barMask = new Sprite();
         addChild(barMask);
         bar.mask = barMask;
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.STYLES))
         {
            drawPattern();
            invalidate(InvalidationType.SIZE,false);
         }
         if(isInvalid(InvalidationType.SIZE))
         {
            drawBar();
            drawMask();
         }
         super.draw();
      }
      
      protected function drawPattern() : void
      {
         var _loc1_:DisplayObject = getDisplayObjectInstance(getStyleValue("indeterminateSkin"));
         if(patternBmp)
         {
            patternBmp.dispose();
         }
         patternBmp = new BitmapData(_loc1_.width << 0,_loc1_.height << 0,true,0);
         patternBmp.draw(_loc1_);
      }
      
      protected function drawMask() : void
      {
         var _loc1_:Graphics = barMask.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,0);
         _loc1_.drawRect(0,0,_width,_height);
         _loc1_.endFill();
      }
      
      protected function drawBar() : void
      {
         if(patternBmp == null)
         {
            return;
         }
         var _loc1_:Graphics = bar.graphics;
         _loc1_.clear();
         _loc1_.beginBitmapFill(patternBmp);
         _loc1_.drawRect(0,0,_width + patternBmp.width,_height);
         _loc1_.endFill();
      }
   }
}
