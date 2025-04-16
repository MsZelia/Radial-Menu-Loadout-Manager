package
{
   import Shared.AS3.BSScrollingList;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import scaleform.gfx.Extensions;
   import scaleform.gfx.TextFieldEx;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol496")]
   public class SecureTradePlayerInventory extends SecureTradeInventory
   {
       
      
      public var Tooltip_mc:MovieClip;
      
      public var PlayerCurrency_tf:TextField;
      
      public var PlayerWeight_tf:TextField;
      
      private var m_Tooltip:String;
      
      private var m_Currency:Number = 0;
      
      private var m_CurrencyMax:Number = 0;
      
      private var m_CurrencyName:String = "";
      
      private var m_CarryWeightCurrent:Number = 0;
      
      private var m_CarryWeightMax:Number = 0;
      
      private var m_AbsoluteWeightLimit:Number = 9999;
      
      private var m_showTooltip:* = false;
      
      public function SecureTradePlayerInventory()
      {
         super();
         addFrameScript(0,this.frame1);
         this.tooltip = "";
         this.UpdateTooltipVisibility();
         Extensions.enabled = true;
         TextFieldEx.setTextAutoSize(this.PlayerWeight_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         TextFieldEx.setTextAutoSize(this.PlayerCurrency_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
      }
      
      public function set currency(param1:Number) : void
      {
         this.m_Currency = param1;
         SetIsDirty();
      }
      
      public function set currencyMax(param1:Number) : void
      {
         this.m_CurrencyMax = param1;
      }
      
      public function set currencyName(param1:String) : void
      {
         this.m_CurrencyName = param1;
      }
      
      public function set tooltip(param1:String) : void
      {
         this.m_Tooltip = param1;
         this.Tooltip_mc.Tooltip_tf.text = param1;
      }
      
      public function get tooltip() : String
      {
         return this.m_Tooltip;
      }
      
      public function set showTooltip(param1:Boolean) : void
      {
         this.m_showTooltip = param1;
         this.UpdateTooltipVisibility();
      }
      
      public function UpdateToolTipText() : void
      {
         var _loc1_:Object = ItemList_mc.List_mc.selectedEntry;
         if(_loc1_ != null && _loc1_.declineReason != undefined && _loc1_.declineReason != -1)
         {
            this.tooltip = "$SecureTrade_" + SecureTradeDeclineItemModal.REJECT_REASONS[_loc1_.declineReason];
         }
         else
         {
            this.tooltip = "";
         }
      }
      
      private function UpdateTooltipVisibility() : void
      {
         if(this.m_showTooltip && !hasEventListener(BSScrollingList.SELECTION_CHANGE))
         {
            addEventListener(BSScrollingList.SELECTION_CHANGE,this.onTooltipSelectionChange);
         }
         else if(!this.m_showTooltip && hasEventListener(BSScrollingList.SELECTION_CHANGE))
         {
            removeEventListener(BSScrollingList.SELECTION_CHANGE,this.onTooltipSelectionChange);
         }
      }
      
      private function onTooltipSelectionChange(param1:Event) : void
      {
         this.UpdateToolTipText();
      }
      
      public function get currency() : Number
      {
         return this.m_Currency;
      }
      
      public function get currencyMax() : Number
      {
         return this.m_CurrencyMax;
      }
      
      public function get currencyName() : String
      {
         return this.m_CurrencyName;
      }
      
      public function set carryWeightCurrent(param1:Number) : void
      {
         this.m_CarryWeightCurrent = param1;
         SetIsDirty();
      }
      
      public function set carryWeightMax(param1:Number) : void
      {
         this.m_CarryWeightMax = param1;
         SetIsDirty();
      }
      
      public function set absoluteWeightLimit(param1:Number) : void
      {
         this.m_AbsoluteWeightLimit = param1;
         SetIsDirty();
      }
      
      public function get carryWeightCurrent() : Number
      {
         return this.m_CarryWeightCurrent;
      }
      
      public function get carryWeightMax() : Number
      {
         return this.m_CarryWeightMax;
      }
      
      public function get absoluteWeightLimit() : Number
      {
         return this.m_AbsoluteWeightLimit;
      }
      
      override public function redrawUIComponent() : void
      {
         super.redrawUIComponent();
         if(this.m_CarryWeightCurrent >= this.m_AbsoluteWeightLimit)
         {
            this.PlayerWeight_tf.text = "$AbsoluteWeightLimitDisplay";
            this.PlayerWeight_tf.text = this.PlayerWeight_tf.text.replace("{weight}",this.m_CarryWeightCurrent.toString());
         }
         else
         {
            this.PlayerWeight_tf.text = this.m_CarryWeightCurrent + "/" + this.m_CarryWeightMax;
         }
         this.PlayerCurrency_tf.text = this.m_Currency.toString();
      }
      
      internal function frame1() : *
      {
      }
   }
}
