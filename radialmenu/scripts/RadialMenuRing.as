package
{
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import flash.display.MovieClip;
   
   public class RadialMenuRing extends MovieClip
   {
       
      
      public var RadialEntry0_mc:MovieClip;
      
      public var RadialEntry1_mc:MovieClip;
      
      public var RadialEntry2_mc:MovieClip;
      
      public var RadialEntry3_mc:MovieClip;
      
      public var RadialEntry4_mc:MovieClip;
      
      public var RadialEntry5_mc:MovieClip;
      
      public var RadialEntry6_mc:MovieClip;
      
      public var RadialEntry7_mc:MovieClip;
      
      public var RadialEntry8_mc:MovieClip;
      
      public var RadialEntry9_mc:MovieClip;
      
      public var RadialEntry10_mc:MovieClip;
      
      public var RadialEntry11_mc:MovieClip;
      
      public var RadialEntry12_mc:MovieClip;
      
      public var RadialEntry13_mc:MovieClip;
      
      public var RadialEntry14_mc:MovieClip;
      
      public var RadialEntry15_mc:MovieClip;
      
      protected var ENTRY_MAX:* = 12;
      
      private var m_SelectedIndex:int = -1;
      
      private var m_Entries:Vector.<RadialMenuEntry>;
      
      private var m_Data:Object;
      
      private var m_Keyboard:uint = 0;
      
      protected var m_SelectedEntry:RadialMenuEntry;
      
      protected var m_ShowKeyLabels:Boolean = false;
      
      public function RadialMenuRing()
      {
         super();
         this.visible = false;
      }
      
      protected function setSelectedIndex(param1:int) : void
      {
         this.m_SelectedIndex = param1;
         if(this.m_SelectedIndex >= 0)
         {
            this.m_SelectedEntry = this.m_Entries[param1];
         }
         else
         {
            this.m_SelectedEntry = null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Entries.length)
         {
            this.m_Entries[_loc2_].selected = _loc2_ == this.m_SelectedIndex;
            _loc2_++;
         }
      }
      
      public function set showKeyLabels(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(param1 != this.m_ShowKeyLabels)
         {
            this.m_ShowKeyLabels = param1;
            _loc2_ = 0;
            while(_loc2_ < this.m_Entries.length)
            {
               this.m_Entries[_loc2_].showKeyLabel = this.m_ShowKeyLabels;
               _loc2_++;
            }
         }
      }
      
      public function set keyboardType(param1:uint) : void
      {
         this.m_Keyboard = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Entries.length)
         {
            this.m_Entries[_loc2_].updateIndexAndHotkeys(_loc2_,this.m_Keyboard);
            _loc2_++;
         }
      }
      
      public function get keyboardType() : uint
      {
         return this.m_Keyboard;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this.setSelectedIndex(param1);
      }
      
      public function get selectedIndex() : int
      {
         return this.m_SelectedIndex;
      }
      
      public function get selectedEntry() : RadialMenuEntry
      {
         return this.m_SelectedEntry;
      }
      
      public function open() : *
      {
         this.visible = true;
      }
      
      public function close() : *
      {
         this.visible = false;
      }
      
      public function updateRotation(param1:Number) : *
      {
         var _loc2_:RadialMenuEntry = null;
         this.rotation = param1;
         var _loc3_:int = 0;
         while(_loc3_ < this.ENTRY_MAX)
         {
            _loc2_ = this.getChildByName("RadialEntry" + _loc3_ + "_mc") as RadialMenuEntry;
            if(_loc2_ != null)
            {
               _loc2_.updateRotation();
            }
            _loc3_++;
         }
      }
      
      private function onStateUpdate(param1:FromClientDataEvent) : *
      {
         var _loc2_:Object = param1.data;
         if(_loc2_.selectedIndex != this.m_SelectedIndex)
         {
            this.selectedIndex = _loc2_.selectedIndex;
         }
      }
      
      protected function onListUpdate(param1:FromClientDataEvent) : *
      {
         var _loc3_:Object = null;
         var _loc4_:RadialMenuEntry = null;
         var _loc2_:Object = param1.data;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.items.length)
         {
            _loc3_ = _loc2_.items[_loc5_];
            (_loc4_ = this.m_Entries[_loc5_]).itemVisible = _loc3_.visible;
            _loc4_.exists = _loc3_.exists;
            _loc4_.icon = _loc3_.icon;
            _loc4_.data = _loc3_;
            _loc4_.level = _loc3_.itemLevel;
            _loc4_.currentHealth = _loc3_.currentHealth;
            _loc4_.maximumHealth = _loc3_.maximumHealth;
            _loc4_.ammoAvailable = _loc3_.ammoAvailable;
            _loc4_.ammoName = _loc3_.ammoName;
            _loc5_++;
         }
         this.m_Data = _loc2_;
      }
      
      public function subscribeList(param1:String) : *
      {
         BSUIDataManager.Subscribe(param1,this.onListUpdate);
      }
      
      public function subscribeState(param1:String) : *
      {
         BSUIDataManager.Subscribe(param1,this.onStateUpdate);
      }
      
      protected function CreateEntries() : *
      {
         var _loc1_:RadialMenuEntry = null;
         this.m_Entries = new Vector.<RadialMenuEntry>();
         var _loc2_:int = 0;
         while(_loc2_ < this.ENTRY_MAX)
         {
            _loc1_ = this.getChildByName("RadialEntry" + _loc2_ + "_mc") as RadialMenuEntry;
            if(_loc1_ != null)
            {
               _loc1_.updateIndexAndHotkeys(_loc2_,this.m_Keyboard);
               this.m_Entries.push(_loc1_);
            }
            _loc2_++;
         }
      }
      
      public function FadeDown() : *
      {
         var _loc1_:RadialMenuEntry = null;
         if(this.currentFrame < 10)
         {
            this.gotoAndPlay("cold");
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.ENTRY_MAX)
         {
            _loc1_ = this.getChildByName("RadialEntry" + _loc2_ + "_mc") as RadialMenuEntry;
            if(_loc1_ != null)
            {
               _loc1_.Backer_mc.alpha = 0.3;
            }
            _loc2_++;
         }
      }
      
      public function FadeUp() : *
      {
         var _loc1_:RadialMenuEntry = null;
         if(this.currentFrame >= 10)
         {
            this.gotoAndPlay("hot");
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.ENTRY_MAX)
         {
            _loc1_ = this.getChildByName("RadialEntry" + _loc2_ + "_mc") as RadialMenuEntry;
            if(_loc1_ != null)
            {
               _loc1_.Backer_mc.alpha = 0.8;
            }
            _loc2_++;
         }
      }
   }
}
