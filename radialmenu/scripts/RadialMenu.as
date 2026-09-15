package
{
   import Shared.AS3.BSButtonHintBar;
   import Shared.AS3.BSButtonHintData;
   import Shared.AS3.BSScrollingList;
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.Events.CustomEvent;
   import Shared.AS3.Events.PlatformChangeEvent;
   import Shared.AS3.IMenu;
   import Shared.AS3.SWFLoaderClip;
   import Shared.AS3.StyleSheet;
   import Shared.AS3.Styles.Radial_RadialInventoryListStyle;
   import Shared.GlobalFunc;
   import Shared.ResolutionDarkeners;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getTimer;
   import scaleform.gfx.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol668")]
   public class RadialMenu extends IMenu
   {
      
      public static const EVENT_SLOT_ITEM:String = "Radial::SlotItem";
      
      public static const EVENT_USE_QUICK_CAMP:String = "Radial::PlaceQuickCamp";
      
      public static var MENU_ID_NONE:int = -1;
      
      public static var MENU_ID_FAVORITES:int = 0;
      
      public static var MENU_ID_EMOTES:int = 1;
      
      public static var MENU_ID_PET_EMOTES:int = 2;
      
      public static var MENU_ID_WORLD_PET_DIRECT:int = 3;
      
      public static var MENU_ID_WORLD_PET_REMOTE:int = 4;
      
      private static var TEST_MODE:Boolean = false;
      
      private static const FILTER_NEW_FAVE:* = 3;
      
      private static const FILTER_NEW_WEAPONS:* = 6;
      
      private static const FILTER_WEAPONS:* = 1 << 2;
      
      private static const FILTER_ARMOR:* = 1 << 3;
      
      private static const FILTER_APPAREL:* = 1 << 4;
      
      private static const FILTER_FOODWATER:* = 1 << 5;
      
      private static const FILTER_AID:* = 1 << 6;
      
      private static const MOVE_DIR_UP:int = 1;
      
      private static const MOVE_DIR_DOWN:int = -1;
      
      private static const SCROLL_REPEAT_DELAY:Number = 150;
      
      public var ButtonHintBar_mc:BSButtonHintBar;
      
      public var Empty_mc:MovieClip;
      
      public var CenterInfo_mc:MovieClip;
      
      public var Background_mc:MovieClip;
      
      public var BackgroundTier2_mc:MovieClip;
      
      public var radialTab:MovieClip;
      
      public var ModeBlade_mc:MovieClip;
      
      public var BladeFill_mc:MovieClip;
      
      public var PlayerInventory_mc:SecureTradePlayerInventory;
      
      private var m_SelectedList:SecureTradeInventory = this.PlayerInventory_mc;
      
      private var m_TabMax:* = 0;
      
      private var m_TabMin:* = 0;
      
      private var m_SelectedTab:int = 1;
      
      private const REPEAT_INTERVAL:Number = 200;
      
      private var m_PlayerInventoryEmpty:Boolean = false;
      
      protected var ButtonHintMouseScrollNavigate:BSButtonHintData = new BSButtonHintData("$SCROLL","Mousewheel","","",1,null);
      
      protected var ButtonHintNavigate:BSButtonHintData = new BSButtonHintData("$SELECT","Space","PSN_RS","Xenon_RS",1,null);
      
      protected var ButtonHintSay:BSButtonHintData = new BSButtonHintData("$SAY","Space","PSN_A","Xenon_A",1,null);
      
      protected var ButtonHintExpand:BSButtonHintData = new BSButtonHintData("$EXPAND","Q","PSN_R1","Xenon_R1",1,null);
      
      protected var ButtonHintSurvivalTent:BSButtonHintData;
      
      protected var ButtonHintSlotItem:BSButtonHintData;
      
      protected var ButtonHintInspectItem:BSButtonHintData = new BSButtonHintData("$INSPECT","X","PSN_R3","Xenon_R3",1,null);
      
      protected var ButtonHintCustomizePetItem:BSButtonHintData = new BSButtonHintData("$CUSTOMIZE","R","PSN_Y","Xenon_Y",1,null);
      
      protected var ButtonHintEditNameItem:BSButtonHintData = new BSButtonHintData("$EDIT_NAME","N","PSN_R3","Xenon_R3",1,null);
      
      protected var ButtonHintSwitchWheelItem:BSButtonHintData = new BSButtonHintData("$SHOW_COMMAND_WHEEL","E","PSN_X","Xenon_X",1,null);
      
      public var SelectedImage_mc:SWFLoaderClip;
      
      public var SelectedImageInstance:MovieClip;
      
      public var OuterRing:RadialMenuRingOuter;
      
      public var InnerRing:RadialMenuRingInner;
      
      public var DpadMap_mc:MovieClip;
      
      public var DpadLine_mc:MovieClip;
      
      public var selectedMenuIndex:int = -1;
      
      private var showDpad:Boolean = true;
      
      private var m_testEnabled:Boolean = false;
      
      public var showInventory:Boolean = false;
      
      private var _ConditionMeterEnabled:Boolean = true;
      
      private var m_HasZeus:Boolean = false;
      
      private var m_CanPlaceQuickCamp:Boolean = false;
      
      private var m_QuickCampPlaceCost:uint = 0;
      
      private var m_HasWorldPet:Boolean = false;
      
      private var m_NextScrollTime:Number = 0;
      
      private var m_LastCenterInfo:* = null;
      
      private var testStateData:Object = {
         "innerSelectedIndex":-1,
         "outerSelectedIndex":-1,
         "innerExpanded":false,
         "menuIndex":-1
      };
      
      public function RadialMenu()
      {
         this.ButtonHintSurvivalTent = new BSButtonHintData("$SURVIVALTENTZEUS","T","PSN_Y","Xenon_Y",1,this.onPlaceQuickCamp);
         this.ButtonHintSlotItem = new BSButtonHintData("$CHANGE","C","PSN_R1","Xenon_R1",1,this.onSlotItem);
         super();
         addFrameScript(0,this.frame1,1,this.frame2);
         StyleSheet.apply(this.PlayerInventory_mc.ItemList_mc,false,Radial_RadialInventoryListStyle);
         this.SelectedImage_mc = this.CenterInfo_mc.IconContainer_mc.Body;
         this.CenterInfo_mc.emoteTitleText_tf.text = "";
         this.CenterInfo_mc.radialCategoryText_tf.text = "";
         this.CenterInfo_mc.ammoInfo_mc.ammoInfo_tf.text = "";
         this.CenterInfo_mc.visible = false;
         this.DpadMap_mc.visible = false;
         this.DpadLine_mc.visible = false;
         this.PlayerInventory_mc.enabled = false;
         this.SelectedImage_mc.clipScale = 1.7;
         this.SelectedImage_mc.clipAlpha = 1;
         this.SelectedImage_mc.centerClip = true;
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         if(TEST_MODE)
         {
            this.registerTestFunctionality();
         }
         this.populateButtonBar();
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusChange);
         addEventListener(BSScrollingList.ITEM_PRESS,this.onItemPress);
         addEventListener(BSScrollingList.SELECTION_CHANGE,this.onSelectionChange);
         addEventListener(SecureTradeInventory.MOUSE_OVER,this.onListMouseOver);
         addEventListener(RadialMenuEntry.MOUSE_OVER,this.onRadialMenuEntryMouseOver);
         this.ButtonHintNavigate.ButtonVisible = true;
         this.ButtonHintMouseScrollNavigate.ButtonVisible = false;
         this.ButtonHintSay.ButtonVisible = false;
         this.ButtonHintSlotItem.ButtonVisible = false;
         this.ButtonHintExpand.ButtonVisible = false;
         this.ButtonHintExpand.ButtonDisabled = true;
         this.ButtonHintSurvivalTent.ButtonEnabled = false;
         this.ButtonHintSurvivalTent.ButtonVisible = false;
         this.ButtonHintCustomizePetItem.ButtonVisible = false;
         this.ButtonHintEditNameItem.ButtonVisible = false;
         this.ButtonHintSwitchWheelItem.ButtonVisible = false;
         addEventListener(PlatformChangeEvent.PLATFORM_CHANGE,this.onPlatformChange);
         RadialMenuLoadoutConfig.init(this);
         addEventListener(KeyboardEvent.KEY_UP,RadialMenuLoadoutConfig.onKeyUp,false,int.MAX_VALUE);
      }
      
      private function populateButtonBar() : void
      {
         var _loc1_:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
         _loc1_.push(this.ButtonHintSurvivalTent);
         _loc1_.push(this.ButtonHintMouseScrollNavigate);
         _loc1_.push(this.ButtonHintNavigate);
         _loc1_.push(this.ButtonHintSay);
         _loc1_.push(this.ButtonHintSlotItem);
         _loc1_.push(this.ButtonHintInspectItem);
         _loc1_.push(this.ButtonHintCustomizePetItem);
         _loc1_.push(this.ButtonHintEditNameItem);
         _loc1_.push(this.ButtonHintSwitchWheelItem);
         _loc1_.push(this.ButtonHintExpand);
         this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
      }
      
      override public function SetPlatform(param1:uint, param2:Boolean, param3:uint, param4:uint) : *
      {
         super.SetPlatform(param1,param2,param3,param4);
         this.updateButtonBar();
         this.InnerRing.keyboardType = uiKeyboard;
         this.OuterRing.keyboardType = uiKeyboard;
      }
      
      private function updateButtonBar() : void
      {
         var _loc1_:Boolean = false;
         this.ButtonHintSurvivalTent.ButtonVisible = this.selectedMenuIndex == MENU_ID_FAVORITES && !this.showInventory;
         this.ButtonHintSurvivalTent.ButtonEnabled = true;
         if(this.m_QuickCampPlaceCost > 0)
         {
            this.ButtonHintSurvivalTent.ButtonText = GlobalFunc.LocalizeFormattedString("$SURVIVALTENTZEUSCOST",this.m_QuickCampPlaceCost);
         }
         else
         {
            this.ButtonHintSurvivalTent.ButtonText = "$SURVIVALTENTZEUS";
         }
         this.ButtonHintSay.ButtonVisible = false;
         this.ButtonHintCustomizePetItem.ButtonVisible = false;
         this.ButtonHintEditNameItem.ButtonVisible = false;
         this.ButtonHintSwitchWheelItem.ButtonVisible = false;
         this.ButtonHintExpand.ButtonVisible = false;
         this.ButtonHintSlotItem.ButtonVisible = false;
         this.ButtonHintInspectItem.ButtonVisible = false;
         if(this.selectedMenuIndex == MENU_ID_EMOTES)
         {
            _loc1_ = this.InnerRing.selectedEntry ? Boolean(this.InnerRing.selectedEntry.data.expandable) : false;
            this.ButtonHintSay.ButtonVisible = true;
            this.ButtonHintSay.ButtonText = "$SAY";
            this.ButtonHintExpand.ButtonVisible = true;
            this.ButtonHintExpand.ButtonEnabled = _loc1_;
            if(this.OuterRing.selectedIndex > -1)
            {
               this.ButtonHintExpand.ButtonText = "$COLLAPSE";
            }
            else
            {
               this.ButtonHintExpand.ButtonText = "$EXPAND";
            }
            this.ButtonHintSwitchWheelItem.ButtonVisible = this.m_HasWorldPet;
            this.ButtonHintSwitchWheelItem.ButtonText = "$SHOW_PET_COMMAND_WHEEL";
         }
         else if(this.selectedMenuIndex == MENU_ID_FAVORITES)
         {
            this.ButtonHintSay.ButtonVisible = true;
            this.ButtonHintSay.ButtonText = "$RADIAL_MENU_USE";
            this.ButtonHintSlotItem.ButtonVisible = !this.showInventory;
            this.ButtonHintInspectItem.ButtonVisible = !this.showInventory;
            if(Boolean(this.InnerRing.selectedEntry) && Boolean(this.InnerRing.selectedEntry.data.isRepairable))
            {
               this.ButtonHintInspectItem.ButtonText = "$INSPECT/REPAIR";
            }
            else
            {
               this.ButtonHintInspectItem.ButtonText = "$INSPECT";
            }
         }
         else if(this.selectedMenuIndex == MENU_ID_WORLD_PET_REMOTE)
         {
            this.ButtonHintCustomizePetItem.ButtonVisible = true;
            this.ButtonHintCustomizePetItem.ButtonText = "$CUSTOMIZE";
            this.ButtonHintEditNameItem.ButtonVisible = true;
            this.ButtonHintEditNameItem.ButtonText = "$EDIT_NAME";
            this.ButtonHintSwitchWheelItem.ButtonVisible = true;
            this.ButtonHintSwitchWheelItem.ButtonText = "$SHOW_EMOTE_WHEEL";
         }
         else if(this.selectedMenuIndex == MENU_ID_WORLD_PET_DIRECT)
         {
            this.ButtonHintCustomizePetItem.ButtonVisible = true;
            this.ButtonHintCustomizePetItem.ButtonText = "$CUSTOMIZE";
            this.ButtonHintEditNameItem.ButtonVisible = true;
            this.ButtonHintEditNameItem.ButtonText = "$EDIT_NAME";
         }
         this.ButtonHintMouseScrollNavigate.ButtonVisible = uiController == PlatformChangeEvent.PLATFORM_PC_KB_MOUSE && !this.showInventory;
      }
      
      public function updateDpad(param1:int) : *
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case MENU_ID_PET_EMOTES:
               _loc2_ = "left";
               this.radialTab.tabText_tf.text = "$EMOTES_PET";
               this.ButtonHintInspectItem.ButtonVisible = false;
               break;
            case MENU_ID_WORLD_PET_DIRECT:
               _loc2_ = "right";
               this.radialTab.tabText_tf.text = "$WORLD_PET_COMMANDS";
               this.ButtonHintInspectItem.ButtonVisible = false;
               break;
            case MENU_ID_FAVORITES:
               _loc2_ = "up";
               this.radialTab.tabText_tf.text = "$FAVORITES";
               break;
            case MENU_ID_EMOTES:
               _loc2_ = "down";
               this.radialTab.tabText_tf.text = "$EMOTES";
               break;
            case MENU_ID_WORLD_PET_REMOTE:
               _loc2_ = "down";
               this.radialTab.tabText_tf.text = "$WORLD_PET_COMMANDS";
         }
         this.updateFillWidth(this.radialTab.tabText_tf);
         this.DpadMap_mc.gotoAndStop(_loc2_);
      }
      
      private function updateFillWidth(param1:TextField) : void
      {
         param1.autoSize = TextFieldAutoSize.LEFT;
         var _loc2_:Number = param1.textWidth + param1.textHeight + 10;
         var _loc3_:Number = 60;
         this.radialTab.ModeBlade_mc.BladeFill_mc.width = _loc2_ + _loc3_;
      }
      
      public function onMenuSelect(param1:int) : void
      {
         if(param1 > MENU_ID_NONE)
         {
            if(this.showDpad)
            {
               this.DpadMap_mc.visible = true;
               this.updateDpad(param1);
            }
            else
            {
               this.DpadMap_mc.visible = false;
            }
            this.DpadLine_mc.visible = true;
            this.Background_mc.gotoAndPlay("rollOn");
            this.InnerRing.open();
         }
         else
         {
            this.DpadMap_mc.visible = false;
            this.DpadLine_mc.visible = false;
            this.Background_mc.gotoAndPlay("rollOff");
            this.InnerRing.close();
         }
         this.selectedMenuIndex = param1;
      }
      
      private function populateCenterInfo(param1:Object) : void
      {
         this.m_LastCenterInfo = param1;
         if(this.SelectedImageInstance != null)
         {
            this.SelectedImage_mc.removeChild(this.SelectedImageInstance);
            this.SelectedImageInstance = null;
         }
         if(param1 != null)
         {
            this.CenterInfo_mc.gotoAndPlay("rollOn");
            switch(this.selectedMenuIndex)
            {
               case MENU_ID_FAVORITES:
                  if(param1.count != null && param1.count > 1)
                  {
                     this.CenterInfo_mc.emoteTitleText_tf.text = param1.name + " (" + param1.count + ")";
                  }
                  else
                  {
                     this.CenterInfo_mc.emoteTitleText_tf.text = param1.name;
                  }
                  break;
               case MENU_ID_EMOTES:
                  this.CenterInfo_mc.emoteTitleText_tf.text = param1.description;
                  break;
               case MENU_ID_PET_EMOTES:
               case MENU_ID_WORLD_PET_DIRECT:
               case MENU_ID_WORLD_PET_REMOTE:
                  this.CenterInfo_mc.emoteTitleText_tf.text = param1.name;
            }
            if(param1.ammoName != null && param1.ammoName != "")
            {
               this.CenterInfo_mc.ammoInfo_mc.ammoInfo_tf.text = param1.ammoName + " (" + param1.ammoAvailable + ")";
            }
            else
            {
               this.CenterInfo_mc.ammoInfo_mc.ammoInfo_tf.text = "";
            }
            this.CenterInfo_mc.ConditionBar_mc.visible = param1.maximumHealth > 0 && this._ConditionMeterEnabled;
            GlobalFunc.updateConditionMeter(this.CenterInfo_mc.ConditionBar_mc.Bar_mc,param1.currentHealth,param1.maximumHealth,param1.durability);
            this.SelectedImageInstance = this.SelectedImage_mc.setContainerIconClip(param1.icon,"","radialIconEmpty");
            this.CenterInfo_mc.IconContainer_mc.transform.colorTransform = null;
            this.CenterInfo_mc.emoteTitleText_tf.textColor = GlobalFunc.COLOR_TEXT_HEADER;
         }
         else
         {
            this.SelectedImageInstance = this.SelectedImage_mc.setContainerIconClip(null,"","radialIconEmpty");
            this.CenterInfo_mc.gotoAndPlay("rollOff");
            this.CenterInfo_mc.ammoInfo_mc.ammoInfo_tf.text = "";
            this.CenterInfo_mc.emoteTitleText_tf.text = "";
            this.CenterInfo_mc.radialCategoryText_tf.text = "";
            this.CenterInfo_mc.ConditionBar_mc.visible = false;
         }
      }
      
      private function processStateUpdate(param1:Object) : *
      {
         var _loc5_:* = undefined;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         this.m_CanPlaceQuickCamp = param1.canPlaceQuickCamp;
         this.m_QuickCampPlaceCost = param1.quickCampMoveCost;
         this.m_HasWorldPet = param1.hasWorldPet;
         this.CenterInfo_mc.ConditionBar_mc.visible = false;
         if(param1.menuIndex != this.selectedMenuIndex)
         {
            this.InnerRing.expanded = false;
            this.onMenuSelect(param1.menuIndex);
            _loc4_ = true;
         }
         if(param1.menuIndex > MENU_ID_NONE)
         {
            _loc3_ = true;
         }
         if(this.InnerRing.selectedIndex != param1.innerSelectedIndex)
         {
            this.InnerRing.selectedIndex = param1.innerSelectedIndex;
            _loc2_ = true;
         }
         if(param1.innerExpanded != this.InnerRing.expanded)
         {
            this.InnerRing.expanded = param1.innerExpanded;
            if(param1.innerExpanded)
            {
               this.OuterRing.open();
            }
            else
            {
               this.OuterRing.close();
            }
            if(this.showDpad && this.BackgroundTier2_mc != null)
            {
               if(param1.innerExpanded)
               {
                  this.BackgroundTier2_mc.gotoAndPlay("secondTierRollOn");
                  this.DpadLine_mc.gotoAndPlay("expand");
               }
               else
               {
                  this.BackgroundTier2_mc.gotoAndPlay("rollOff");
                  this.DpadLine_mc.gotoAndPlay("collapse");
               }
            }
            _loc2_ = true;
         }
         if(this.OuterRing.selectedIndex != param1.outerSelectedIndex)
         {
            this.OuterRing.selectedIndex = param1.outerSelectedIndex;
            this.OuterRing.updateRotation(30 * (this.InnerRing.selectedIndex + 1));
            _loc2_ = true;
         }
         _loc2_ = true;
         if(_loc2_)
         {
            if(!param1.innerExpanded && (this.InnerRing.selectedEntry == null || !this.InnerRing.selectedEntry.exists))
            {
               _loc3_ = false;
            }
            _loc5_ = null;
            if(param1.innerExpanded && param1.outerSelectedIndex > -1 && this.OuterRing.selectedEntry != null)
            {
               _loc5_ = this.OuterRing.selectedEntry.data;
            }
            else if(param1.innerSelectedIndex > -1 && this.InnerRing.selectedEntry != null)
            {
               _loc5_ = this.InnerRing.selectedEntry.data;
            }
            if(_loc5_ != this.m_LastCenterInfo && (_loc5_ == null || _loc5_.visible))
            {
               this.populateCenterInfo(_loc5_);
            }
         }
         if(this.OuterRing.selectedIndex > -1)
         {
            this.InnerRing.FadeDown();
            this.OuterRing.FadeUp();
         }
         else
         {
            this.InnerRing.FadeUp();
            this.OuterRing.FadeDown();
         }
         this.CenterInfo_mc.visible = _loc3_;
         this.updateButtonBar();
         this.updateShowHotkeys();
      }
      
      private function onStateUpdate(param1:FromClientDataEvent) : *
      {
         if(param1.data.testEnable == true && this.m_testEnabled == false)
         {
            this.registerTestFunctionality();
         }
         var _loc2_:Object = param1.data;
         this.processStateUpdate(_loc2_);
      }
      
      private function processMeterFillUpdate(param1:Object) : *
      {
         if(this.InnerRing.selectedEntry != null)
         {
            (this.InnerRing.selectedEntry as RadialMenuEntryInner).fillPercent = param1.fillMeterPercent;
         }
      }
      
      private function onMeterFillUpdate(param1:FromClientDataEvent) : *
      {
         var _loc2_:Object = param1.data;
         this.processMeterFillUpdate(_loc2_);
      }
      
      protected function onRadialMenuEntryMouseOver(param1:Event) : void
      {
         var _loc2_:* = false;
         if(!this.showInventory)
         {
            _loc2_ = param1.target is RadialMenuEntryInner;
            BSUIDataManager.dispatchEvent(new CustomEvent("RadialMenu::OnMouseHover",{
               "isInnerRing":_loc2_,
               "selectedIndex":param1.target.index
            }));
            if(RadialMenuLoadoutConfig.DEBUG_SELECTION)
            {
               RadialMenuLoadoutConfig.displayError("selection changed:\n" + RadialMenuLoadoutConfig.toJSON(param1.target.data));
            }
         }
      }
      
      private function onPlatformChange(param1:PlatformChangeEvent) : void
      {
         this.updateShowHotkeys();
      }
      
      private function updateShowHotkeys() : void
      {
         var _loc1_:Boolean = uiController == PlatformChangeEvent.PLATFORM_PC_KB_MOUSE && this.selectedMenuIndex == MENU_ID_FAVORITES;
         this.InnerRing.showKeyLabels = _loc1_;
         this.OuterRing.showKeyLabels = _loc1_;
         this.ButtonHintMouseScrollNavigate.ButtonVisible = uiController == PlatformChangeEvent.PLATFORM_PC_KB_MOUSE && !this.showInventory;
      }
      
      public function onAdded(param1:Event) : void
      {
         BSUIDataManager.Subscribe("RadialMenuStateData",this.onStateUpdate);
         BSUIDataManager.Subscribe("RadialMenuExpandMeterData",this.onMeterFillUpdate);
         BSUIDataManager.Subscribe("PlayerInventoryData",this.onPlayerInventoryDataUpdate);
         BSUIDataManager.Subscribe("CharacterInfoData",this.onCharacterInfoDataUpdate);
         BSUIDataManager.Subscribe("AccountInfoData",this.onAccountInfoUpdate);
         BSUIDataManager.Subscribe("ScreenResolutionData",this.onScreenResolutionData);
         this.updateSelfInventory();
      }
      
      private function onScreenResolutionData(param1:FromClientDataEvent) : void
      {
         var _loc2_:Shape = null;
         if(param1.data)
         {
            _loc2_ = ResolutionDarkeners.CreateDarkener(param1.data.ScreenWidth,param1.data.ScreenHeight,ResolutionDarkeners.DARKENER_TYPE_SOLID,0.3);
            addChildAt(_loc2_,0);
            ResolutionDarkeners.PositionDarkener(_loc2_);
            this.radialTab.gotoAndStop(param1.data.AspectRatio);
         }
      }
      
      private function onAccountInfoUpdate(param1:FromClientDataEvent) : void
      {
         this.m_HasZeus = param1.data.hasZeus;
         this.updateButtonBar();
      }
      
      private function onListMouseOver(param1:Event) : *
      {
         if(param1.target == this.PlayerInventory_mc && this.selectedList != this.PlayerInventory_mc)
         {
            this.selectedList = this.PlayerInventory_mc;
         }
      }
      
      private function onSelectionChange(param1:Event) : *
      {
         if(this.selectedList != null)
         {
            if(this.selectedListEntry != null)
            {
               if(param1 != null)
               {
                  GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_FOCUS_CHANGE);
               }
            }
         }
      }
      
      private function onItemPress(param1:Event) : *
      {
         if(this.showInventory)
         {
            this.onSlotItem();
            GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_OK);
         }
      }
      
      private function onFocusChange(param1:FocusEvent) : *
      {
         if(param1.relatedObject != this.PlayerInventory_mc.ItemList_mc.List_mc)
         {
            stage.focus = param1.target as InteractiveObject;
         }
      }
      
      private function ClearAndSortListData(param1:Array) : Array
      {
         var index:int = 0;
         var item:Object = null;
         var aListData:Array = param1;
         var newArray:Array = [];
         if(aListData != null)
         {
            index = 0;
            while(index < aListData.length)
            {
               item = aListData[index];
               if(Boolean(item.canFavorite) && (item.filterFlag == FILTER_WEAPONS || item.filterFlag == FILTER_NEW_WEAPONS || item.filterFlag == FILTER_NEW_FAVE || item.filterFlag == FILTER_ARMOR || item.filterFlag == FILTER_APPAREL || item.filterFlag == FILTER_AID || item.filterFlag == FILTER_FOODWATER))
               {
                  newArray.push(item);
               }
               index++;
            }
            newArray.sort(function(param1:Object, param2:Object):int
            {
               var _loc3_:int = 0;
               var _loc4_:int = 10;
               if(param1.filterFlag == FILTER_WEAPONS || param1.filterFlag == FILTER_NEW_FAVE || param1.filterFlag == FILTER_NEW_WEAPONS)
               {
                  _loc4_ = 1;
               }
               else if(param1.filterFlag == FILTER_ARMOR || param1.filterFlag == FILTER_APPAREL)
               {
                  _loc4_ = 2;
               }
               if(param1.filterFlag == FILTER_FOODWATER || param1.filterFlag == FILTER_AID)
               {
                  _loc4_ = 3;
               }
               var _loc5_:int = 10;
               if(param2.filterFlag == FILTER_WEAPONS || param2.filterFlag == FILTER_NEW_FAVE || param2.filterFlag == FILTER_NEW_WEAPONS)
               {
                  _loc5_ = 1;
               }
               else if(param2.filterFlag == FILTER_ARMOR || param2.filterFlag == FILTER_APPAREL)
               {
                  _loc5_ = 2;
               }
               if(param2.filterFlag == FILTER_FOODWATER || param2.filterFlag == FILTER_AID)
               {
                  _loc5_ = 3;
               }
               if(_loc4_ < _loc5_)
               {
                  _loc3_ = -1;
               }
               else if(_loc4_ > _loc5_)
               {
                  _loc3_ = 1;
               }
               if(_loc3_ == 0)
               {
                  if(param1.text < param2.text)
                  {
                     _loc3_ = -1;
                  }
                  else if(param1.text > param2.text)
                  {
                     _loc3_ = 1;
                  }
                  else if(param1.count < param2.count)
                  {
                     _loc3_ = -1;
                  }
                  else if(param1.count > param2.count)
                  {
                     _loc3_ = 1;
                  }
               }
               return _loc3_;
            });
         }
         return newArray;
      }
      
      private function updateSelfInventory() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         if(this.PlayerInventory_mc.enabled)
         {
            _loc1_ = new Array();
            _loc2_ = new Array();
            _loc3_ = new Array();
            _loc4_ = null;
            _loc5_ = 0;
            _loc4_ = BSUIDataManager.GetDataFromClient("PlayerInventoryData").data;
            if(_loc4_ != null && _loc4_.InventoryList != null)
            {
               this.PlayerInventory_mc.ItemList_mc.List_mc.filterer.itemFilter = FILTER_WEAPONS + FILTER_ARMOR + FILTER_APPAREL + FILTER_AID + FILTER_FOODWATER;
               this.PlayerInventory_mc.ItemList_mc.List_mc.MenuListData = this.ClearAndSortListData(_loc4_.InventoryList.concat());
            }
            else
            {
               this.PlayerInventory_mc.ItemList_mc.List_mc.MenuListData = null;
            }
            this.PlayerInventory_mc.ItemList_mc.SetIsDirty();
            this.onSelectionChange(null);
         }
      }
      
      private function IsInventoryEmpty(param1:MovieClip) : Boolean
      {
         return param1.ItemList_mc.List_mc.MenuListData.length == 0;
      }
      
      private function onCharacterInfoDataUpdate(param1:FromClientDataEvent) : void
      {
         PlayerListEntry.playerLevel = param1.data.level;
      }
      
      private function onPlayerInventoryDataUpdate(param1:FromClientDataEvent) : void
      {
         this.updateSelfInventory();
         if(this.selectedMenuIndex == MENU_ID_FAVORITES && this.InnerRing.selectedEntry != null && this.InnerRing.selectedEntry.exists)
         {
            this.m_LastCenterInfo = this.InnerRing.selectedEntry.data;
            this.populateCenterInfo(this.InnerRing.selectedEntry.data);
         }
         this.m_PlayerInventoryEmpty = this.IsInventoryEmpty(this.PlayerInventory_mc);
         if(this.selectedList == this.PlayerInventory_mc)
         {
            this.PlayerInventory_mc.selectedItemIndex = this.m_PlayerInventoryEmpty ? -1 : this.PlayerInventory_mc.ItemList_mc.List_mc.filterer.ClampIndex(this.PlayerInventory_mc.selectedItemIndex);
         }
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         var _loc3_:* = false;
         RadialMenuLoadoutConfig.ProcessUserEvent(param1,param2);
         if(this.selectedMenuIndex == MENU_ID_EMOTES)
         {
            _loc3_ = param1 == "PlaceQuickCamp";
         }
         else if(this.selectedMenuIndex == MENU_ID_FAVORITES)
         {
            if(this.showInventory && param1 == "ForceClose")
            {
               _loc3_ = false;
               this.onSlotItemCancel();
            }
            else
            {
               _loc3_ = this.showInventory;
            }
            if(!param2)
            {
               if(!this.showInventory)
               {
                  if(param1 == "ShowInventory" && this.InnerRing.selectedEntry != null)
                  {
                     this.onShowInventory();
                  }
                  else if(param1 == "PlaceQuickCamp")
                  {
                     this.onPlaceQuickCamp();
                  }
               }
               else
               {
                  switch(param1)
                  {
                     case "Select":
                        this.onSlotItem();
                        break;
                     case "Cancel":
                        this.onSlotItemCancel();
                        break;
                     case "InventoryUp":
                     case "InventoryDown":
                        this.m_NextScrollTime = 0;
                  }
               }
            }
            else if(this.showInventory && uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
            {
               switch(param1)
               {
                  case "InventoryUp":
                     this.tryMoveSelection(MOVE_DIR_UP);
                     break;
                  case "InventoryDown":
                     this.tryMoveSelection(MOVE_DIR_DOWN);
               }
            }
         }
         this.updateButtonBar();
         return _loc3_;
      }
      
      private function tryMoveSelection(param1:int) : void
      {
         var _loc2_:Number = getTimer();
         if(_loc2_ >= this.m_NextScrollTime)
         {
            if(param1 == MOVE_DIR_UP)
            {
               this.m_SelectedList.ItemList_mc.List_mc.moveSelectionUp();
            }
            else if(param1 == MOVE_DIR_DOWN)
            {
               this.m_SelectedList.ItemList_mc.List_mc.moveSelectionDown();
            }
            this.m_NextScrollTime = _loc2_ + SCROLL_REPEAT_DELAY;
         }
      }
      
      public function ProcessThumbstick(param1:int) : Boolean
      {
         var _loc2_:Boolean = this.showInventory;
         if(this.showInventory)
         {
            switch(param1)
            {
               case GlobalFunc.DIRECTION_UP:
                  this.m_SelectedList.ItemList_mc.List_mc.moveSelectionUp();
                  break;
               case GlobalFunc.DIRECTION_DOWN:
                  this.m_SelectedList.ItemList_mc.List_mc.moveSelectionDown();
            }
         }
         return _loc2_;
      }
      
      public function onSlotItemCancel() : void
      {
         this.gotoAndStop("radialOnly");
         this.showInventory = false;
         this.PlayerInventory_mc.enabled = true;
         GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_CANCEL);
      }
      
      private function onSlotItem() : void
      {
         BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_SLOT_ITEM,{
            "serverHandleID":this.selectedListEntry.serverHandleID,
            "slotId":this.InnerRing.selectedIndex
         }));
         this.gotoAndStop("radialOnly");
         this.showInventory = false;
         this.PlayerInventory_mc.enabled = true;
         GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_OK);
      }
      
      private function onPlaceQuickCamp() : void
      {
         BSUIDataManager.dispatchEvent(new Event(EVENT_USE_QUICK_CAMP));
         GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_OK);
      }
      
      public function onShowInventory() : void
      {
         this.PlayerInventory_mc.enabled = true;
         this.updateSelfInventory();
         this.gotoAndStop("radialInventory");
         this.showInventory = true;
         this.selectedList = this.PlayerInventory_mc;
         GlobalFunc.PlayMenuSound(GlobalFunc.MENU_SOUND_OK);
      }
      
      public function set selectedList(param1:SecureTradeInventory) : *
      {
         if(param1 != this.m_SelectedList)
         {
            this.m_SelectedList = param1;
            stage.focus = this.m_SelectedList.ItemList_mc.List_mc;
         }
      }
      
      public function get selectedList() : SecureTradeInventory
      {
         return this.m_SelectedList;
      }
      
      public function get selectedListEntry() : Object
      {
         return this.m_SelectedList.ItemList_mc.List_mc.selectedEntry;
      }
      
      public function get selectedListIndex() : int
      {
         return this.m_SelectedList.ItemList_mc.List_mc.selectedIndex;
      }
      
      private function onTestKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         _loc2_ = 1;
         if(param1.shiftKey)
         {
            _loc2_ *= -1;
         }
         switch(param1.keyCode)
         {
            case 116:
               _loc3_ = this.testStateData.menuIndex + _loc2_;
               _loc3_ = Math.max(MENU_ID_NONE,Math.min(_loc3_,MENU_ID_WORLD_PET_DIRECT));
               this.testStateData.menuIndex = _loc3_;
               this.processStateUpdate(this.testStateData);
               break;
            case 117:
               _loc4_ = int(this.testStateData.innerSelectedIndex);
               _loc4_ += _loc2_;
               _loc4_ = Math.max(-1,Math.min(_loc4_,11));
               this.testStateData.innerSelectedIndex = _loc4_;
               this.processStateUpdate(this.testStateData);
               break;
            case 118:
               this.testStateData.innerExpanded = !this.testStateData.innerExpanded;
               this.processStateUpdate(this.testStateData);
               break;
            case 119:
               _loc5_ = int(this.testStateData.outerSelectedIndex);
               _loc5_ += _loc2_;
               _loc5_ = Math.max(-1,Math.min(_loc5_,15));
               this.testStateData.outerSelectedIndex = _loc5_;
               this.processStateUpdate(this.testStateData);
               break;
            case 114:
               _loc6_ = Math.random();
               this.processMeterFillUpdate({"fillMeterPercent":_loc6_});
         }
      }
      
      public function registerTestFunctionality() : void
      {
         this.m_testEnabled = true;
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onTestKeyDown);
      }
      
      public function DisableConditionMeter() : *
      {
         this._ConditionMeterEnabled = false;
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
   }
}

