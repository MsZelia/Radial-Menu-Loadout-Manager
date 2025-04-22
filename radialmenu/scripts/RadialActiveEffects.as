package
{
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.IMenu;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol460")]
   public class RadialActiveEffects extends IMenu
   {
      
      public static const ACTIVE_EFFECT_PADDING:int = 7;
      
      public static const ACTIVE_EFFECT_BUFFER:int = 12;
       
      
      public var Header_tf:TextField;
      
      public var EntryList_mc:MovieClip;
      
      public var BG_mc:MovieClip;
      
      private var bgHeight:Number = 0;
      
      public function RadialActiveEffects()
      {
         super();
         BSUIDataManager.Subscribe("RadialMenuActiveEffectListData",this.onActiveEffectsUpdate);
      }
      
      private function onActiveEffectsUpdate(param1:FromClientDataEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:RadialActiveEffectEntry = null;
         this.EntryList_mc.removeChildren();
         if(param1.data != null)
         {
            _loc2_ = param1.data.activeEffectItems;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].effectName != "")
               {
                  (_loc5_ = new RadialActiveEffectEntry()).UpdateEffectEntry(_loc2_[_loc3_]);
                  _loc5_.y = this.EntryList_mc.numChildren * (_loc5_.height + ACTIVE_EFFECT_PADDING);
                  this.EntryList_mc.addChild(_loc5_);
               }
               _loc3_++;
            }
            _loc4_ = 0;
            if(this.EntryList_mc.numChildren > 0)
            {
               _loc4_ = this.EntryList_mc.numChildren * (_loc5_.height + ACTIVE_EFFECT_PADDING) + ACTIVE_EFFECT_BUFFER * 2;
            }
            this.bgHeight = _loc4_;
            this.BG_mc.height = this.bgHeight;
         }
      }
   }
}
