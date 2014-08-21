package fl.controls
{
   import fl.core.UIComponent;
   import fl.controls.progressBarClasses.IndeterminateBar;
   import flash.display.DisplayObject;
   import fl.core.InvalidationType;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   
   public class ProgressBar extends UIComponent
   {
      
      public function ProgressBar()
      {
         super();
      }
      
      private static var defaultStyles:Object = {
         "trackSkin":"ProgressBar_trackSkin",
         "barSkin":"ProgressBar_barSkin",
         "indeterminateSkin":"ProgressBar_indeterminateSkin",
         "indeterminateBar":IndeterminateBar,
         "barPadding":0
      };
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      protected var track:DisplayObject;
      
      protected var determinateBar:DisplayObject;
      
      protected var indeterminateBar:UIComponent;
      
      protected var _direction:String = "right";
      
      protected var _indeterminate:Boolean = true;
      
      protected var _mode:String = "event";
      
      protected var _minimum:Number = 0;
      
      protected var _maximum:Number = 0;
      
      protected var _value:Number = 0;
      
      protected var _source:Object;
      
      protected var _loaded:Number;
      
      public function get direction() : String
      {
         return _direction;
      }
      
      public function set direction(param1:String) : void
      {
         _direction = param1;
         invalidate(InvalidationType.DATA);
      }
      
      public function get indeterminate() : Boolean
      {
         return _indeterminate;
      }
      
      public function set indeterminate(param1:Boolean) : void
      {
         if(!(_mode == ProgressBarMode.MANUAL) || _indeterminate == param1)
         {
            return;
         }
         setIndeterminate(param1);
      }
      
      public function get minimum() : Number
      {
         return _minimum;
      }
      
      public function set minimum(param1:Number) : void
      {
         if(_mode != ProgressBarMode.MANUAL)
         {
            return;
         }
         _minimum = param1;
         invalidate(InvalidationType.DATA);
      }
      
      public function get maximum() : Number
      {
         return _maximum;
      }
      
      public function set maximum(param1:Number) : void
      {
         setProgress(_value,param1);
      }
      
      public function get value() : Number
      {
         return _value;
      }
      
      public function set value(param1:Number) : void
      {
         setProgress(param1,_maximum);
      }
      
      public function setProgress(param1:Number, param2:Number) : void
      {
         if(_mode != ProgressBarMode.MANUAL)
         {
            return;
         }
         _setProgress(param1,param2);
      }
      
      public function set sourceName(param1:String) : void
      {
         if(!componentInspectorSetting)
         {
            return;
         }
         if(param1 == "")
         {
            return;
         }
         var _loc2_:DisplayObject = parent.getChildByName(param1) as DisplayObject;
         if(_loc2_ == null)
         {
            throw new Error("Source clip \'" + param1 + "\' not found on parent.");
         }
         else
         {
            source = _loc2_;
            return;
         }
      }
      
      public function get source() : Object
      {
         return _source;
      }
      
      public function set source(param1:Object) : void
      {
         if(_source == param1)
         {
            return;
         }
         if(_mode != ProgressBarMode.MANUAL)
         {
            resetProgress();
         }
         _source = param1;
         if(_source == null)
         {
            return;
         }
         if(_mode == ProgressBarMode.EVENT)
         {
            setupSourceEvents();
         }
         else if(_mode == ProgressBarMode.POLLED)
         {
            addEventListener(Event.ENTER_FRAME,pollSource,false,0,true);
         }
         
      }
      
      public function get percentComplete() : Number
      {
         return _maximum <= _minimum || _value <= _minimum?0:Math.max(0,Math.min(100,(_value - _minimum) / (_maximum - _minimum) * 100));
      }
      
      public function get mode() : String
      {
         return _mode;
      }
      
      public function set mode(param1:String) : void
      {
         if(_mode == param1)
         {
            return;
         }
         resetProgress();
         _mode = param1;
         if(param1 == ProgressBarMode.EVENT && !(_source == null))
         {
            setupSourceEvents();
         }
         else if(param1 == ProgressBarMode.POLLED)
         {
            addEventListener(Event.ENTER_FRAME,pollSource,false,0,true);
         }
         
         setIndeterminate(!(_mode == ProgressBarMode.MANUAL));
      }
      
      public function reset() : void
      {
         _setProgress(0,0);
         var _loc1_:Object = _source;
         _source = null;
         source = _loc1_;
      }
      
      protected function _setProgress(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         if(param1 == _value && param2 == _maximum)
         {
            return;
         }
         _value = param1;
         _maximum = param2;
         if(!(_value == _loaded) && (param3))
         {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,_value,_maximum));
            _loaded = _value;
         }
         if(_mode != ProgressBarMode.MANUAL)
         {
            setIndeterminate(param2 == 0);
         }
         invalidate(InvalidationType.DATA);
      }
      
      protected function setIndeterminate(param1:Boolean) : void
      {
         if(_indeterminate == param1)
         {
            return;
         }
         _indeterminate = param1;
         invalidate(InvalidationType.STATE);
      }
      
      protected function resetProgress() : void
      {
         if(_mode == ProgressBarMode.EVENT && !(_source == null))
         {
            cleanupSourceEvents();
         }
         else if(_mode == ProgressBarMode.POLLED)
         {
            removeEventListener(Event.ENTER_FRAME,pollSource);
         }
         else if(_source != null)
         {
            _source = null;
         }
         
         
         _minimum = _maximum = _value = 0;
      }
      
      protected function setupSourceEvents() : void
      {
         _source.addEventListener(ProgressEvent.PROGRESS,handleProgress,false,0,true);
         _source.addEventListener(Event.COMPLETE,handleComplete,false,0,true);
      }
      
      protected function cleanupSourceEvents() : void
      {
         _source.removeEventListener(ProgressEvent.PROGRESS,handleProgress);
         _source.removeEventListener(Event.COMPLETE,handleComplete);
      }
      
      protected function pollSource(param1:Event) : void
      {
         if(_source == null)
         {
            return;
         }
         _setProgress(_source.bytesLoaded,_source.bytesTotal,true);
         if(_maximum > 0 && _maximum == _value)
         {
            removeEventListener(Event.ENTER_FRAME,pollSource);
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      protected function handleProgress(param1:ProgressEvent) : void
      {
         _setProgress(param1.bytesLoaded,param1.bytesTotal,true);
      }
      
      protected function handleComplete(param1:Event) : void
      {
         _setProgress(_maximum,_maximum,true);
         dispatchEvent(param1);
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.STYLES))
         {
            drawTrack();
            drawBars();
            invalidate(InvalidationType.STATE,false);
            invalidate(InvalidationType.SIZE,false);
         }
         if(isInvalid(InvalidationType.STATE))
         {
            indeterminateBar.visible = _indeterminate;
            determinateBar.visible = !_indeterminate;
            invalidate(InvalidationType.DATA,false);
         }
         if(isInvalid(InvalidationType.SIZE))
         {
            drawLayout();
            invalidate(InvalidationType.DATA,false);
         }
         if((isInvalid(InvalidationType.DATA)) && !_indeterminate)
         {
            drawDeterminateBar();
         }
         super.draw();
      }
      
      protected function drawTrack() : void
      {
         var _loc1_:DisplayObject = track;
         track = getDisplayObjectInstance(getStyleValue("trackSkin"));
         addChildAt(track,0);
         if(!(_loc1_ == null) && !(_loc1_ == track))
         {
            removeChild(_loc1_);
         }
      }
      
      protected function drawBars() : void
      {
         var _loc1_:DisplayObject = determinateBar;
         var _loc2_:DisplayObject = indeterminateBar;
         determinateBar = getDisplayObjectInstance(getStyleValue("barSkin"));
         addChild(determinateBar);
         indeterminateBar = getDisplayObjectInstance(getStyleValue("indeterminateBar")) as UIComponent;
         indeterminateBar.setStyle("indeterminateSkin",getStyleValue("indeterminateSkin"));
         addChild(indeterminateBar);
         if(!(_loc1_ == null) && !(_loc1_ == determinateBar))
         {
            removeChild(_loc1_);
         }
         if(!(_loc2_ == null) && !(_loc2_ == determinateBar))
         {
            removeChild(_loc2_);
         }
      }
      
      protected function drawDeterminateBar() : void
      {
         var _loc1_:Number = percentComplete / 100;
         var _loc2_:Number = Number(getStyleValue("barPadding"));
         determinateBar.width = Math.round((width - _loc2_ * 2) * _loc1_);
         determinateBar.x = _direction == ProgressBarDirection.LEFT?width - _loc2_ - determinateBar.width:_loc2_;
      }
      
      protected function drawLayout() : void
      {
         var _loc1_:Number = Number(getStyleValue("barPadding"));
         track.width = width;
         track.height = height;
         indeterminateBar.setSize(width - _loc1_ * 2,height - _loc1_ * 2);
         indeterminateBar.move(_loc1_,_loc1_);
         indeterminateBar.drawNow();
         determinateBar.height = height - _loc1_ * 2;
         determinateBar.y = _loc1_;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
      }
   }
}
