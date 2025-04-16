package
{
   import Shared.AS3.SWFLoaderClip;
   import Shared.GlobalFunc;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol326")]
   public class RadialInventoryListEntry extends PlayerListEntry
   {
       
      
      public var Icon_mc:MovieClip;
      
      protected var m_IconClip:SWFLoaderClip;
      
      protected var m_IconInstance:MovieClip;
      
      private var m_Icon:String;
      
      public function RadialInventoryListEntry()
      {
         super();
      }
      
      override public function SetEntryText(param1:Object, param2:String) : *
      {
         super.SetEntryText(param1,param2);
         var _loc3_:* = new ColorTransform();
         RarityBorder_mc.visible = param1.nwRarity > -1 ? true : false;
         RaritySelector_mc.visible = false;
         if(param1.nwRarity == 0)
         {
            _loc3_.color = GlobalFunc.COLOR_RARITY_COMMON;
            RarityIndicator_mc.gotoAndStop(GlobalFunc.FRAME_RARITY_COMMON);
         }
         else if(param1.nwRarity == 1)
         {
            _loc3_.color = GlobalFunc.COLOR_RARITY_RARE;
            RarityIndicator_mc.gotoAndStop(GlobalFunc.FRAME_RARITY_RARE);
         }
         else if(param1.nwRarity == 2)
         {
            _loc3_.color = GlobalFunc.COLOR_RARITY_EPIC;
            RarityIndicator_mc.gotoAndStop(GlobalFunc.FRAME_RARITY_EPIC);
         }
         else if(param1.nwRarity == 3)
         {
            _loc3_.color = GlobalFunc.COLOR_RARITY_LEGENDARY;
            RarityIndicator_mc.gotoAndStop(GlobalFunc.FRAME_RARITY_LEGENDARY);
         }
         else
         {
            _loc3_.color = GlobalFunc.COLOR_TEXT_BODY;
            RarityIndicator_mc.gotoAndStop(GlobalFunc.FRAME_RARITY_NONE);
         }
         RaritySelector_mc.RarityOverlay_mc.transform.colorTransform = _loc3_;
         RarityBorder_mc.transform.colorTransform = _loc3_;
         RarityIndicator_mc.transform.colorTransform = _loc3_;
         if(selected)
         {
            if(param1.nwRarity > -1)
            {
               border.visible = false;
               RaritySelector_mc.visible = true;
            }
         }
         if(playerLevel >= param1.itemLevel)
         {
         }
      }
   }
}
