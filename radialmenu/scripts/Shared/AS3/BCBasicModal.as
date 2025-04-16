package Shared.AS3
{
   import Shared.AS3.Styles.MessageBoxButtonListStyle;
   import Shared.GlobalFunc;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import scaleform.gfx.TextFieldEx;
   
   public class BCBasicModal extends BSUIComponent
   {
      
      public static const EVENT_CONFIRM:* = "BSBasicModal::Confirm";
      
      public static const EVENT_CANCEL:String = "BSBasicModal::Cancel";
      
      public static const EVENT_ENTRY_SELECTED:String = "BSBasicModal::EntrySelected";
      
      public static const VALUE_ICON_SPACING:Number = 6;
      
      public static const ELEMENT_X_PADDING:Number = 24;
      
      public static const ELEMENT_Y_SPACING:Number = 12;
      
      public static const ELEMENT_Y_PADDING:Number = 25;
      
      public static const BUTTON_MODE_NONE:uint = 0;
      
      public static const BUTTON_MODE_LIST:uint = 1;
      
      public static const BUTTON_MODE_BAR:uint = 2;
      
      public static const BACKGROUND_MINWIDTH:Number = 750;
       
      
      public var Header_mc:MovieClip;
      
      public var Tooltip_mc:MovieClip;
      
      public var TooltipExtra_mc:MovieClip;
      
      public var Value_mc:MovieClip;
      
      public var Background_mc:MovieClip;
      
      public var ButtonHintBar_mc:BSButtonHintBar;
      
      public var ButtonList_mc:MessageBoxButtonList;
      
      public var ComponentList_mc:BSScrollingList;
      
      public var Internal_mc:MovieClip;
      
      private var m_PreviousFocus:InteractiveObject;
      
      private var m_ChoiceButtonMode:uint = 0;
      
      private var m_Tooltip:String;
      
      private var m_TooltipExtra:String;
      
      private var m_ButtonBarInitialized:Boolean = false;
      
      private var m_ButtonListInitialized:Boolean = false;
      
      private var m_ButtonListCustom:Array;
      
      private var m_DynamicLayout:Boolean = true;
      
      protected var m_AcceptButton:BSButtonHintData;
      
      protected var m_CancelButton:BSButtonHintData;
      
      private var m_Open:Boolean = false;
      
      public function BCBasicModal()
      {
         this.m_AcceptButton = new BSButtonHintData("$ACCEPT","Space","PSN_A","Xenon_A",1,this.onConfirm);
         this.m_CancelButton = new BSButtonHintData("$CANCEL","TAB","PSN_B","Xenon_B",1,this.onCancel);
         super();
         if(this.Internal_mc != null)
         {
            this.Header_mc = this.Internal_mc.Header_mc;
            this.Tooltip_mc = this.Internal_mc.Tooltip_mc;
            this.TooltipExtra_mc = this.Internal_mc.TooltipExtra_mc;
            this.Value_mc = this.Internal_mc.Value_mc;
            this.Background_mc = this.Internal_mc.Background_mc;
            this.ButtonHintBar_mc = this.Internal_mc.ButtonHintBar_mc;
            this.ButtonList_mc = this.Internal_mc.ButtonList_mc;
            this.ComponentList_mc = this.Internal_mc.ComponentList_mc;
         }
         TextFieldEx.setTextAutoSize(this.Header_mc.textField,TextFieldEx.TEXTAUTOSZ_SHRINK);
         if(this.ButtonList_mc != null)
         {
            StyleSheet.apply(this.ButtonList_mc,false,MessageBoxButtonListStyle);
         }
         addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         mouseEnabled = false;
         mouseChildren = false;
         SetIsDirty();
      }
      
      public function set dynamicLayout(param1:Boolean) : void
      {
         this.m_DynamicLayout = param1;
         SetIsDirty();
      }
      
      public function set customButtonList(param1:Array) : void
      {
         var _loc2_:uint = 0;
         if(param1 != null)
         {
            _loc2_ = param1.length;
            if(_loc2_ > 0 && _loc2_ <= 10)
            {
               this.m_ButtonListCustom = param1;
               SetIsDirty();
            }
            else
            {
               trace("WARNING: BCBasicModal::customButtonList - List expects 1-10 entries, but has " + _loc2_);
            }
         }
      }
      
      public function set choiceButtonMode(param1:uint) : void
      {
         this.m_ChoiceButtonMode = param1;
         SetIsDirty();
      }
      
      public function get choiceButtonMode() : uint
      {
         return this.m_ChoiceButtonMode;
      }
      
      public function set previousFocus(param1:InteractiveObject) : void
      {
         this.m_PreviousFocus = param1;
      }
      
      public function get previousFocus() : InteractiveObject
      {
         return this.m_PreviousFocus;
      }
      
      public function set header(param1:String) : *
      {
         this.Header_mc.textField.text = param1;
         SetIsDirty();
      }
      
      public function get tooltip() : String
      {
         return this.Tooltip_mc.textField.text;
      }
      
      public function set tooltip(param1:String) : *
      {
         this.Tooltip_mc.textField.text = param1;
         this.m_Tooltip = param1;
         if(this.Tooltip_mc != null)
         {
            if(this.m_Tooltip.length > 0)
            {
               this.Tooltip_mc.visible = true;
            }
            else
            {
               this.Tooltip_mc.visible = false;
            }
         }
         SetIsDirty();
      }
      
      public function set tooltipExtra(param1:String) : *
      {
         this.TooltipExtra_mc.textField.text = param1;
         this.m_TooltipExtra = param1;
         if(this.TooltipExtra_mc != null)
         {
            if(this.m_TooltipExtra.length > 0)
            {
               this.TooltipExtra_mc.visible = true;
            }
            else
            {
               this.TooltipExtra_mc.visible = false;
            }
         }
         SetIsDirty();
      }
      
      public function set value(param1:String) : *
      {
         if(this.Value_mc != null)
         {
            this.Value_mc.Value_tf.text = param1;
            SetIsDirty();
         }
      }
      
      public function get open() : Boolean
      {
         return this.m_Open;
      }
      
      public function set open(param1:Boolean) : *
      {
         if(param1 != this.m_Open)
         {
            this.m_Open = param1;
            if(this.m_Open)
            {
               gotoAndPlay("rollOn");
               if(this.ButtonList_mc != null && this.m_ChoiceButtonMode == BUTTON_MODE_LIST)
               {
                  this.ButtonList_mc.selectedIndex = 0;
                  stage.focus = this.ButtonList_mc;
               }
            }
            else
            {
               gotoAndPlay("rollOff");
            }
            mouseEnabled = this.m_Open;
            mouseChildren = this.m_Open;
         }
      }
      
      public function onKeyUp(param1:KeyboardEvent) : *
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.onConfirm();
         }
      }
      
      protected function onConfirm() : void
      {
         dispatchEvent(new Event(EVENT_CONFIRM,true,true));
      }
      
      protected function onCancel() : void
      {
         dispatchEvent(new Event(EVENT_CANCEL,true,true));
      }
      
      override public function redrawUIComponent() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Array = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:uint = 0;
         if(this.Value_mc != null)
         {
            _loc1_ = [this.Value_mc.Value_tf];
            if(this.Value_mc.Icon_mc != null)
            {
               _loc1_.push(this.Value_mc.Icon_mc);
            }
            GlobalFunc.arrangeItems(_loc1_,false,GlobalFunc.ALIGN_CENTER,VALUE_ICON_SPACING);
         }
         if(this.ButtonHintBar_mc != null)
         {
            this.ButtonHintBar_mc.redrawUIComponent();
            if(this.m_ChoiceButtonMode == BUTTON_MODE_BAR)
            {
               this.initializeButtonBar();
            }
            this.ButtonHintBar_mc.visible = this.m_ChoiceButtonMode == BUTTON_MODE_BAR;
         }
         if(this.ButtonList_mc != null)
         {
            if(this.m_ChoiceButtonMode == BUTTON_MODE_LIST)
            {
               this.populateButtonList();
            }
            this.ButtonList_mc.visible = this.m_ChoiceButtonMode == BUTTON_MODE_LIST;
         }
         if(this.ComponentList_mc != null)
         {
            if(this.ComponentList_mc.ScrollUp != null)
            {
               this.ComponentList_mc.ScrollUp.y = this.ComponentList_mc.ScrollUp.height / 2;
            }
            if(this.ComponentList_mc.ScrollDown != null)
            {
               this.ComponentList_mc.ScrollDown.y = this.ComponentList_mc.shownItemsHeight - this.ComponentList_mc.ScrollDown.height / 2;
            }
         }
         if(this.m_DynamicLayout)
         {
            this.Background_mc.width = Math.max(BACKGROUND_MINWIDTH,this.Background_mc.width);
            this.Header_mc.textField.width = this.Background_mc.width - ELEMENT_X_PADDING * 2;
            this.Header_mc.textField.x = this.Header_mc.textField.width / -2;
            _loc2_ = this.Background_mc.width;
            _loc3_ = (loaderInfo.width - _loc2_) / 2;
            _loc4_ = _loc3_ + _loc2_ / 2;
            _loc5_ = [this.Header_mc];
            if(this.Tooltip_mc != null && this.m_Tooltip != null && this.m_Tooltip.length > 0)
            {
               _loc5_.push(this.Tooltip_mc);
            }
            if(this.TooltipExtra_mc != null && this.m_TooltipExtra != null && this.m_TooltipExtra.length > 0)
            {
               _loc5_.push(this.TooltipExtra_mc);
            }
            if(this.ComponentList_mc != null)
            {
               this.ComponentList_mc.x = _loc4_;
               _loc5_.push(this.ComponentList_mc);
            }
            if(this.Value_mc != null)
            {
               _loc5_.push(this.Value_mc);
            }
            if(this.ButtonHintBar_mc != null && this.ButtonHintBar_mc.visible)
            {
               this.ButtonHintBar_mc.x = _loc4_;
               _loc5_.push(this.ButtonHintBar_mc);
            }
            if(this.ButtonList_mc != null && this.ButtonList_mc.visible)
            {
               this.ButtonList_mc.x = _loc4_;
               _loc5_.push(this.ButtonList_mc);
            }
            _loc6_ = GlobalFunc.arrangeItems(_loc5_,true,GlobalFunc.ALIGN_LEFT,ELEMENT_Y_SPACING,false,ELEMENT_Y_PADDING) + ELEMENT_Y_PADDING * 2;
            _loc7_ = (stage.stageHeight - _loc6_) / 2;
            this.Background_mc.x = _loc3_;
            this.Background_mc.y = _loc7_;
            this.Background_mc.height = _loc6_;
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc5_[_loc8_].y += _loc7_;
               _loc8_++;
            }
         }
      }
      
      private function onItemPress(param1:Event) : void
      {
         dispatchEvent(new Event(EVENT_ENTRY_SELECTED,true,true));
         if(this.ButtonList_mc.selectedIndex == 0)
         {
            this.onConfirm();
         }
         else
         {
            this.onCancel();
         }
         param1.stopPropagation();
      }
      
      private function populateButtonList() : void
      {
         if(!this.m_ButtonListInitialized)
         {
            addEventListener(BSScrollingList.ITEM_PRESS,this.onItemPress);
         }
         if(this.m_ButtonListCustom != null)
         {
            this.ButtonList_mc.entryList = this.m_ButtonListCustom;
         }
         else
         {
            this.ButtonList_mc.entryList = [{"text":"$OK"},{"text":"$CANCEL"}];
         }
         this.ButtonList_mc.InvalidateData();
         this.ButtonList_mc.selectedIndex = 0;
      }
      
      private function initializeButtonBar() : void
      {
         var _loc1_:Vector.<BSButtonHintData> = null;
         if(!this.m_ButtonBarInitialized)
         {
            _loc1_ = new Vector.<BSButtonHintData>();
            _loc1_.push(this.m_AcceptButton);
            _loc1_.push(this.m_CancelButton);
            this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
         }
      }
   }
}
