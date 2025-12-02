package
{
   [Embed(source="/_assets/assets.swf", symbol="symbol512")]
   public class RadialMenuEntryOuter extends RadialMenuEntry
   {
      
      public function RadialMenuEntryOuter()
      {
         super();
         addFrameScript(1,this.frame2,10,this.frame11,21,this.frame22);
         m_IconClip = Icon_mc.Body;
         m_IconClip.parent.rotation = -this.rotation;
         Hotkey_mc.rotation = -this.rotation;
         m_IconClip.clipScale = 1;
         m_IconClip.clipAlpha = 1;
         m_IconClip.clipWidth = m_IconClip.width;
         m_IconClip.clipHeight = m_IconClip.height;
         m_IconClip.centerClip = true;
      }
      
      private function updateState() : *
      {
         if(m_ItemVisible)
         {
            if(m_Selected)
            {
               gotoAndPlay("rollOn");
            }
            else
            {
               gotoAndPlay("rollOff");
            }
         }
         else
         {
            gotoAndPlay("off");
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
      
      override public function redrawUIComponent() : void
      {
         super.redrawUIComponent();
         Hotkey_mc.visible = m_ShowKeyLabel;
      }
      
      internal function frame2() : *
      {
         stop();
      }
      
      internal function frame11() : *
      {
         stop();
      }
      
      internal function frame22() : *
      {
         stop();
      }
   }
}

