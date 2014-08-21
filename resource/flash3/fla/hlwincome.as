package
{
   import flash.filters.GlowFilter;
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import fl.controls.*;
   import flash.utils.*;
   import ValveLib.*;
   import fl.transitions.Tween;
   import fl.transitions.easing.None;
   
   public class hlwincome extends MovieClip
   {
      
      public function hlwincome()
      {
         var _loc1_:MovieClip = null;
         this.playerpanels = new Vector.<MovieClip>();
         this.goodPlayers = new Vector.<int>();
         this.badPlayers = new Vector.<int>();
         this.goldGlow = new GlowFilter();
         this.nameFormat = new TextFormat();
         this.incomeFormat = new TextFormat();
         this.titleFormat = new TextFormat();
         this.progressbarTimer = new Timer(100);
         super();
         this.playerpanels.push(this.big.player1);
         this.playerpanels.push(this.big.player2);
         this.playerpanels.push(this.big.player3);
         this.playerpanels.push(this.big.player4);
         this.playerpanels.push(this.big.player5);
         this.playerpanels.push(this.big.player6);
         this.playerpanels.push(this.big.player7);
         this.playerpanels.push(this.big.player8);
         this.playerpanels.push(this.big.player9);
         this.playerpanels.push(this.big.player10);
         this.nameFormat.color = 16777215;
         this.nameFormat.size = 30;
         this.nameFormat.align = "left";
         this.nameFormat.bold = "true";
         this.nameFormat.font = "Dota Hypatia Regular";
         this.incomeFormat.color = 16777215;
         this.incomeFormat.size = 30;
         this.incomeFormat.align = "center";
         this.incomeFormat.bold = "true";
         this.incomeFormat.font = "Dota Hypatia Regular";
         this.titleFormat.color = 16777215;
         this.titleFormat.size = 43;
         this.titleFormat.align = "left";
         this.titleFormat.bold = "true";
         this.titleFormat.font = "Dota Hypatia Regular";
         for each(_loc1_ in this.playerpanels)
         {
            _loc1_.playername.playernametext.setTextFormat(this.nameFormat);
            _loc1_.income.incometext.setTextFormat(this.incomeFormat);
         }
         this.small.ownplayer.playername.playernametext.setTextFormat(this.nameFormat);
         this.small.ownplayer.income.incometext.setTextFormat(this.incomeFormat);
         this.big.incometitle.setTextFormat(this.titleFormat);
         this.small.incometitle.setTextFormat(this.titleFormat);
         this.goldGlow.alpha = 0.6;
         this.goldGlow.color = 16763955;
         this.goldGlow.inner = false;
         this.goldGlow.blurX = 0;
         this.goldGlow.blurY = 0;
         this.small.gold.filters = [this.goldGlow];
         this.big.gold.filters = [this.goldGlow];
         this.big.progressbar.myprogress.scaleX = 0;
         this.small.progressbar.myprogress.scaleX = 0;
      }
      
      public var big:MovieClip;
      
      public var small:MovieClip;
      
      public var gameAPI:Object;
      
      public var globals:Object;
      
      public var elementName:String;
      
      public var player1:MovieClip;
      
      public var player2:MovieClip;
      
      public var player3:MovieClip;
      
      public var player4:MovieClip;
      
      public var player5:MovieClip;
      
      public var player6:MovieClip;
      
      public var player7:MovieClip;
      
      public var player8:MovieClip;
      
      public var player9:MovieClip;
      
      public var player10:MovieClip;
      
      public var ownplayer:MovieClip;
      
      public var gold:MovieClip;
      
      public var progressbar:MovieClip;
      
      public var myprogress:MovieClip;
      
      public var extendButton:Button;
      
      public var shrinkButton:Button;
      
      public var playerpanels:Vector.<MovieClip>;
      
      public var goodPlayers:Vector.<int>;
      
      public var badPlayers:Vector.<int>;
      
      public var goldGlow:GlowFilter;
      
      public var maxGoldGlow = 35;
      
      public var nameFormat;
      
      public var incomeFormat;
      
      public var titleFormat;
      
      public var progressbarTimer;
      
      public var currentIncomeMS = 0;
      
      public var incomeMS = 10000;
      
      public var smallProgressBarTween;
      
      public var bigProgressBarTween;
      
      public function onLoaded() : void
      {
         this.gameAPI.SubscribeToGameEvent("hlw_initialize_interface",this.onInitializeInterface);
         this.gameAPI.SubscribeToGameEvent("hlw_close_interface",this.onCloseInterface);
         this.gameAPI.SubscribeToGameEvent("hlw_update_player_name",this.onUpdateName);
         this.gameAPI.SubscribeToGameEvent("hlw_update_player_income",this.onUpdateIncome);
         this.gameAPI.SubscribeToGameEvent("hlw_income",this.onIncome);
         this.small.extendButton.addEventListener(MouseEvent.CLICK,this.extend);
         this.big.shrinkButton.addEventListener(MouseEvent.CLICK,this.shrink);
         this.progressbarTimer.addEventListener(TimerEvent.TIMER,this.timerHandler);
         this.progressbarTimer.reset();
         this.small.visible = false;
         this.big.visible = true;
         visible = false;
         setTimeout(this.gameAPI.SendServerCommand,1000,"hlw_reconnect");
      }
      
      public function timerHandler(param1:TimerEvent) : *
      {
         this.currentIncomeMS = this.currentIncomeMS + this.progressbarTimer.delay;
         if(this.currentIncomeMS > this.incomeMS)
         {
            this.currentIncomeMS = this.incomeMS;
         }
         var _loc2_:* = this.currentIncomeMS / this.incomeMS;
         this.bigProgressBarTween.continueTo(_loc2_,this.progressbarTimer.delay / 1000);
         this.smallProgressBarTween.continueTo(_loc2_,this.progressbarTimer.delay / 1000);
         var _loc3_:* = this.maxGoldGlow * _loc2_;
         this.goldGlow.blurX = _loc3_;
         this.goldGlow.blurY = _loc3_;
         this.small.gold.filters = [this.goldGlow];
         this.big.gold.filters = [this.goldGlow];
      }
      
      public function onScreenSizeChanged() : void
      {
         scaleX = this.globals.resizeManager.ScreenWidth / 1920 * 0.6;
         scaleY = this.globals.resizeManager.ScreenHeight / 1080 * 0.6;
         x = this.globals.resizeManager.ScreenWidth - width;
         y = this.globals.resizeManager.ScreenHeight * 42 / 1080;
      }
      
      public function onInitializeInterface(param1:Object) : *
      {
         this.incomeMS = param1.nIncomeSeconds * 1000;
         this.big.progressbar.maximum = this.incomeMS;
         this.small.progressbar.maximum = this.incomeMS;
         visible = true;
      }
      
      public function onIncome(param1:Object) : *
      {
         this.progressbarTimer.reset();
         this.goldGlow.blurX = 0;
         this.goldGlow.blurY = 0;
         this.small.gold.filters = [this.goldGlow];
         this.big.gold.filters = [this.goldGlow];
         this.currentIncomeMS = 0;
         this.big.progressbar.myprogress.scaleX = 0;
         this.small.progressbar.myprogress.scaleX = 0;
         this.smallProgressBarTween = new Tween(this.small.progressbar.myprogress,"scaleX",None.easeNone,0,0,0,true);
         this.bigProgressBarTween = new Tween(this.big.progressbar.myprogress,"scaleX",None.easeNone,0,0,0,true);
         this.progressbarTimer.start();
      }
      
      public function onCloseInterface(param1:Object) : *
      {
         this.progressbarTimer.stop();
      }
      
      public function onUpdateName(param1:Object) : *
      {
         var _loc2_:* = undefined;
         if(param1.nPlayerID == this.globals.Players.GetLocalPlayer())
         {
            this.small.ownplayer.playername.playernametext.text = this.globals.Players.GetPlayerName(param1.nPlayerID);
            this.small.ownplayer.playername.playernametext.setTextFormat(this.nameFormat);
         }
         var _loc3_:* = -1;
         if(param1.nPlayerTeam == 2)
         {
            _loc3_ = this.goodPlayers.indexOf(param1.nPlayerID);
            if(_loc3_ != -1)
            {
               _loc2_ = this.playerpanels[_loc3_].playername.playernametext;
            }
            else
            {
               _loc2_ = this.playerpanels[this.goodPlayers.push(param1.nPlayerID) - 1].playername.playernametext;
            }
            _loc2_.text = this.globals.Players.GetPlayerName(param1.nPlayerID);
            _loc2_.setTextFormat(this.nameFormat);
         }
         else if(param1.nPlayerTeam == 3)
         {
            _loc3_ = this.badPlayers.indexOf(param1.nPlayerID);
            if(_loc3_ != -1)
            {
               _loc2_ = this.playerpanels[5 + _loc3_].playername.playernametext;
            }
            else
            {
               _loc2_ = this.playerpanels[5 + this.badPlayers.push(param1.nPlayerID) - 1].playername.playernametext;
            }
            _loc2_.text = this.globals.Players.GetPlayerName(param1.nPlayerID);
            _loc2_.setTextFormat(this.nameFormat);
         }
         
      }
      
      public function onUpdateIncome(param1:Object) : *
      {
         if(param1.nPlayerID == this.globals.Players.GetLocalPlayer())
         {
            this.small.ownplayer.income.incometext.text = Math.floor(param1.nIncome).toString();
            this.small.ownplayer.income.incometext.setTextFormat(this.incomeFormat);
         }
         var _loc2_:* = -1;
         _loc2_ = this.goodPlayers.indexOf(param1.nPlayerID);
         if(_loc2_ != -1)
         {
            this.playerpanels[_loc2_].income.incometext.text = Math.floor(param1.nIncome).toString();
            this.playerpanels[_loc2_].income.incometext.setTextFormat(this.incomeFormat);
         }
         else
         {
            _loc2_ = this.badPlayers.indexOf(param1.nPlayerID);
            if(_loc2_ != -1)
            {
               this.playerpanels[_loc2_ + 5].income.incometext.text = Math.floor(param1.nIncome).toString();
               this.playerpanels[_loc2_ + 5].income.incometext.setTextFormat(this.incomeFormat);
            }
         }
         _loc2_ = 0;
      }
      
      public function extend(param1:MouseEvent) : void
      {
         this.globals.GameInterface.PlaySound("General.ButtonClick");
         this.small.visible = false;
         this.big.visible = true;
      }
      
      public function shrink(param1:MouseEvent) : void
      {
         this.globals.GameInterface.PlaySound("General.ButtonClick");
         this.small.visible = true;
         this.big.visible = false;
      }
   }
}
