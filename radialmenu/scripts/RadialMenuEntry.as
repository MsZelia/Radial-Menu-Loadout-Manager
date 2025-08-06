package
{
   import Shared.AS3.BSUIComponent;
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Events.PlatformChangeEvent;
   import Shared.AS3.SWFLoaderClip;
   import fl.transitions.Tween;
   import fl.transitions.easing.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class RadialMenuEntry extends BSUIComponent
   {
      
      public static var UNUSABLE_ALPHA:Number = 0.25;
      
      public static const PC_HOTKEYS_EN:String = "1234567890-=";
      
      public static const PC_HOTKEYS_FR:String = "1234567890)=";
      
      public static const PC_HOTKEYS_BE:String = "1234567890)-";
      
      public static const MOUSE_OVER:String = "RadialMenuEntry::mouse_over";
      
      public var Icon_mc:MovieClip;
      
      public var BackgroundHighlight_mc:MovieClip;
      
      public var Backer_mc:MovieClip;
      
      public var Hotkey_mc:MovieClip;
      
      public var HitArea_mc:MovieClip;
      
      protected var m_IconClip:SWFLoaderClip;
      
      protected var m_IconInstance:MovieClip;
      
      protected var m_Index:int;
      
      private var m_Exists:Boolean = false;
      
      protected var m_Selected:Boolean = false;
      
      private var m_Hotkeys:String = "";
      
      private var m_Data:Object;
      
      private var m_Icon:String;
      
      private var m_isEmpty:Boolean = true;
      
      private var m_Level:uint;
      
      private var m_CurrentHealth:Number;
      
      private var m_MaximumHealth:Number;
      
      private var m_AmmoAvailable:Number;
      
      private var m_AmmoName:String = "";
      
      protected var m_ShowKeyLabel:Boolean = false;
      
      protected var m_ItemVisible:Boolean = true;
      
      private var m_IconAlphaTween:Tween;
      
      public function RadialMenuEntry()
      {
         super();
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(MOUSE_OVER,true,true));
      }
      
      public function set currentHealth(param1:Number) : void
      {
         this.m_CurrentHealth = param1;
         SetIsDirty();
      }
      
      public function set showKeyLabel(param1:Boolean) : void
      {
         if(param1 != this.m_ShowKeyLabel)
         {
            this.m_ShowKeyLabel = param1;
            SetIsDirty();
         }
      }
      
      public function set maximumHealth(param1:Number) : void
      {
         this.m_MaximumHealth = param1;
         SetIsDirty();
      }
      
      public function set ammoAvailable(param1:Number) : void
      {
         this.m_AmmoAvailable = param1;
         SetIsDirty();
      }
      
      public function set ammoName(param1:String) : void
      {
         this.m_AmmoName = param1;
         SetIsDirty();
      }
      
      public function set level(param1:uint) : void
      {
         this.m_Level = param1;
         SetIsDirty();
      }
      
      public function set itemVisible(param1:Boolean) : void
      {
         this.m_ItemVisible = param1;
      }
      
      public function updateIconState() : void
      {
         if(this.m_Selected)
         {
            this.Icon_mc.gotoAndPlay("selected");
         }
         else
         {
            this.Icon_mc.gotoAndPlay("unselected");
         }
      }
      
      public function updateRotation() : *
      {
         this.Icon_mc.Body.parent.rotation = -this.rotation - this.parent.rotation;
      }
      
      public function updateIndexAndHotkeys(param1:uint, param2:uint) : void
      {
         switch(param2)
         {
            case PlatformChangeEvent.PLATFORM_PC_KB_BE:
               this.m_Hotkeys = PC_HOTKEYS_BE;
               break;
            case PlatformChangeEvent.PLATFORM_PC_KB_FR:
               this.m_Hotkeys = PC_HOTKEYS_FR;
               break;
            case PlatformChangeEvent.PLATFORM_PC_KB_ENG:
            default:
               this.m_Hotkeys = PC_HOTKEYS_EN;
         }
         this.m_Index = param1;
         (this.Hotkey_mc.Hotkey_tf as TextField).text = this.m_Hotkeys.charAt(param1);
      }
      
      public function get index() : int
      {
         return this.m_Index;
      }
      
      public function set data(param1:Object) : *
      {
         this.m_Data = param1;
      }
      
      public function get data() : Object
      {
         return this.m_Data;
      }
      
      public function set selected(param1:Boolean) : *
      {
         this.m_Selected = param1;
         this.updateIconState();
      }
      
      public function get selected() : Boolean
      {
         return this.m_Selected;
      }
      
      public function set exists(param1:Boolean) : *
      {
         this.m_Exists = param1;
      }
      
      public function get exists() : Boolean
      {
         return this.m_Exists;
      }
      
      public function set icon(param1:String) : *
      {
         if(param1 != this.m_Icon)
         {
            this.m_Icon = param1;
            if(this.m_Icon == "radialIconEmpty" || this.m_Icon == "" || this.m_Icon == null)
            {
               this.Backer_mc.gotoAndStop(2);
               this.m_isEmpty = true;
            }
            else
            {
               this.Backer_mc.gotoAndStop(1);
               this.m_isEmpty = false;
            }
            if(this.m_IconInstance != null)
            {
               this.m_IconClip.removeChild(this.m_IconInstance);
               this.m_IconInstance = null;
            }
            if(!this.m_isEmpty)
            {
               this.m_IconInstance = this.m_IconClip.setContainerIconClip(this.m_Icon,"","radialIconEmpty");
            }
            if(this.HitArea_mc != null)
            {
               this.hitArea = this.HitArea_mc;
            }
            this.mouseChildren = false;
         }
      }
      
      override public function redrawUIComponent() : void
      {
         var _loc1_:* = BSUIDataManager.GetDataFromClient("CharacterInfoData").data;
         if(!this.m_isEmpty)
         {
            if(this.m_Level <= _loc1_.level && (this.m_AmmoName.length == 0 || this.m_AmmoAvailable > 0) && (this.m_MaximumHealth == 0 || this.m_CurrentHealth > 0))
            {
               this.m_IconInstance.alpha = 1;
            }
            else
            {
               this.m_IconInstance.alpha = UNUSABLE_ALPHA;
            }
         }
      }
   }
}

