package Shared.AS3
{
   import Shared.AS3.Events.MenuActionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   
   public class BCBasicMenu extends MenuComponent
   {
      
      public static const SELECTION_CHANGE:String = "BSScrollingList::selectionChange";
      
      public static const ITEM_PRESS:String = "BSScrollingList::itemPress";
      
      public static const LIST_PRESS:String = "BSScrollingList::listPress";
      
      public static const LIST_ITEMS_CREATED:String = "BSScrollingList::listItemsCreated";
      
      public static const PLAY_FOCUS_SOUND:String = "BSScrollingList::playFocusSound";
       
      
      public var Backer_mc:MovieClip;
      
      protected var m_Entries:Vector.<BCBasicMenuItem>;
      
      private var m_DisableInput:Boolean = false;
      
      private var m_DisableSelection:Boolean = false;
      
      private var m_SelectedIndex:int = -1;
      
      private var m_StoredSelectedIndex:int = 0;
      
      protected var m_Horizontal:Boolean = false;
      
      protected var m_SaveSelection:Boolean = false;
      
      private var m_ButtonPressAction:Function;
      
      private var m_AcceptButton:BSButtonHintData;
      
      private var m_CancelButton:BSButtonHintData;
      
      public function BCBasicMenu()
      {
         this.m_AcceptButton = new BSButtonHintData("$ACCEPT","Enter","PSN_A","Xenon_A",1,this.onItemPress);
         this.m_CancelButton = new BSButtonHintData("$CANCEL","Esc","PSN_B","Xenon_B",1,this.onMenuCancel);
         super();
         addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         this.m_Entries = new Vector.<BCBasicMenuItem>();
      }
      
      protected function setActive(param1:Boolean) : void
      {
         if(param1 != _active)
         {
            if(param1)
            {
               if(this.m_SaveSelection)
               {
                  this.selectedIndex = this.m_StoredSelectedIndex;
               }
               else
               {
                  this.selectedIndex = 0;
               }
            }
            else
            {
               this.m_StoredSelectedIndex = this.m_SelectedIndex;
               this.selectedIndex = -1;
            }
         }
      }
      
      override public function set Active(param1:*) : void
      {
         this.setActive(param1);
         connectButtonBar();
         _active = param1;
      }
      
      public function get selectedIndex() : int
      {
         if(_active)
         {
            return this.m_SelectedIndex;
         }
         return this.m_StoredSelectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(this.m_SelectedIndex != param1)
         {
            this.m_SelectedIndex = param1;
            this.updateSelection();
         }
      }
      
      private function clampIndex(param1:*) : int
      {
         return Math.max(0,Math.min(param1,this.m_Entries.length - 1));
      }
      
      public function selectIncrease() : *
      {
         this.selectedIndex = this.clampIndex(this.selectedIndex + 1);
      }
      
      public function selectDecrease() : *
      {
         this.selectedIndex = this.clampIndex(this.selectedIndex - 1);
      }
      
      public function onKeyDown(param1:KeyboardEvent) : *
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         if(!this.m_DisableInput)
         {
            _loc2_ = Keyboard.UP;
            _loc3_ = Keyboard.DOWN;
            if(this.m_Horizontal)
            {
               _loc2_ = Keyboard.LEFT;
               _loc3_ = Keyboard.RIGHT;
            }
            if(param1.keyCode == _loc2_)
            {
               this.selectDecrease();
               param1.stopPropagation();
            }
            else if(param1.keyCode == _loc3_)
            {
               this.selectIncrease();
               param1.stopPropagation();
            }
         }
      }
      
      public function onKeyUp(param1:KeyboardEvent) : *
      {
         if(!this.m_DisableInput && !this.m_DisableSelection && param1.keyCode == Keyboard.ENTER)
         {
            this.onItemPress();
            param1.stopPropagation();
         }
      }
      
      private function updateSelection() : void
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_Entries.length)
         {
            this.m_Entries[_loc1_].selected = this.m_SelectedIndex == _loc1_;
            _loc1_++;
         }
      }
      
      public function onEntryRollover(param1:Event) : *
      {
         var _loc2_:* = undefined;
         if(!this.m_DisableInput && !this.m_DisableSelection)
         {
            _loc2_ = this.m_SelectedIndex;
            this.selectedIndex = (param1.currentTarget as BCBasicMenuItem).index;
            if(_loc2_ != this.m_SelectedIndex)
            {
               dispatchEvent(new Event(PLAY_FOCUS_SOUND,true,true));
            }
         }
      }
      
      public function onEntryPress(param1:MouseEvent) : *
      {
         param1.stopPropagation();
         this.onItemPress();
      }
      
      public function addItem(param1:BCBasicMenuItem) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onEntryRollover);
         param1.addEventListener(MouseEvent.CLICK,this.onEntryPress);
         param1.index = this.m_Entries.length;
         this.m_Entries.push(param1);
      }
      
      public function set buttonPressAction(param1:Function) : *
      {
         this.m_ButtonPressAction = param1;
      }
      
      protected function onItemPress() : *
      {
      }
      
      private function setFocusUnderMouse() : void
      {
         var _loc2_:Point = null;
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_Entries.length)
         {
            _loc2_ = localToGlobal(new Point(mouseX,mouseY));
            if(this.m_Entries[_loc1_].hitTestPoint(_loc2_.x,_loc2_.y,false))
            {
               this.selectedIndex = _loc1_;
            }
            _loc1_++;
         }
      }
      
      public function onMouseWheel(param1:MouseEvent) : *
      {
         if(param1.delta < 0)
         {
            this.selectIncrease();
         }
         else if(param1.delta > 0)
         {
            this.selectDecrease();
         }
         this.setFocusUnderMouse();
         param1.stopPropagation();
      }
      
      public function onFocusIn(param1:FocusEvent) : void
      {
      }
      
      private function onMenuCancel(param1:Event = null) : *
      {
         if(this.m_CancelButton.ButtonVisible && this.m_CancelButton.ButtonEnabled)
         {
            dispatchEvent(new MenuActionEvent(MenuActionEvent.MENU_CANCEL,null,null));
         }
      }
      
      override public function onAddedToStage() : void
      {
         super.onAddedToStage();
         this.focusRect = false;
         buttonData.push(this.m_AcceptButton);
         buttonData.push(this.m_CancelButton);
         connectButtonBar();
      }
      
      public function collapse() : void
      {
      }
      
      public function expand() : void
      {
      }
   }
}
