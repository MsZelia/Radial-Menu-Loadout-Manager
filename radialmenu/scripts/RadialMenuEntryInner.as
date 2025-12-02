package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol497")]
   public class RadialMenuEntryInner extends RadialMenuEntry
   {
      
      public var Expanded_mc:MovieClip;
      
      public var Fill_mc:MovieClip;
      
      private var m_FillPercent:Number = 0;
      
      private var m_Expanded:Boolean = false;
      
      public function RadialMenuEntryInner()
      {
         super();
         addFrameScript(1,this.frame2,2,this.frame3,14,this.frame15,20,this.frame21);
         m_IconClip = Icon_mc.Body;
         m_IconClip.clipScale = 1;
         m_IconClip.clipAlpha = 1;
         m_IconClip.parent.rotation = -this.rotation;
         Hotkey_mc.rotation = -this.rotation;
         m_IconClip.clipWidth = m_IconClip.width;
         m_IconClip.clipHeight = m_IconClip.height;
         m_IconClip.centerClip = true;
      }
      
      public function set fillPercent(param1:Number) : *
      {
         this.m_FillPercent = param1;
         this.Fill_mc.gotoAndStop(Math.ceil(this.m_FillPercent * 75));
      }
      
      public function get fillPercent() : Number
      {
         return this.m_FillPercent;
      }
      
      private function updateState() : *
      {
         if(m_Selected)
         {
            gotoAndPlay("selectorFadeOn");
         }
         else
         {
            this.fillPercent = 0;
            gotoAndPlay("selectorFadeOff");
         }
      }
      
      override public function set selected(param1:Boolean) : *
      {
         if(m_Selected != param1)
         {
            m_Selected = param1;
            this.updateState();
            updateIconState();
         }
      }
      
      public function set expanded(param1:Boolean) : *
      {
         this.m_Expanded = param1;
         this.updateState();
         SetIsDirty();
      }
      
      public function get expanded() : Boolean
      {
         return this.m_Expanded;
      }
      
      override public function redrawUIComponent() : void
      {
         super.redrawUIComponent();
         Hotkey_mc.visible = !this.m_Expanded && m_ShowKeyLabel;
      }
      
      internal function frame2() : *
      {
         stop();
      }
      
      internal function frame3() : *
      {
         stop();
      }
      
      internal function frame15() : *
      {
         stop();
      }
      
      internal function frame21() : *
      {
         stop();
      }
   }
}

