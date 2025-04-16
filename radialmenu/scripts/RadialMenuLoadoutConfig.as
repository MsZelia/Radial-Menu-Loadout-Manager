package
{
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.Events.CustomEvent;
   import Shared.GlobalFunc;
   import com.adobe.serialization.json.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.net.*;
   import flash.text.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class RadialMenuLoadoutConfig
   {
      
      private static const MOD_NAME:String = "RadialMenuLoadoutManager";
      
      private static const MOD_VERSION:String = "1.0.0";
      
      private static const FULL_MOD_NAME:String = "[" + MOD_NAME + " " + MOD_VERSION + "]";
      
      private static const FILE_NAME:String = "../RadialMenuLoadoutConfig.json";
      
      private static const EVENT_SLOT_ITEM:String = "Radial::SlotItem";
      
      public static var DEBUG:Boolean = false;
      
      public static var DEBUG_SELECTION:Boolean = false;
      
      private static var config:*;
      
      private static var radialMenu:* = null;
      
      private static var PlayerInventoryData:* = null;
      
      private static var CharacterName:String = "";
      
      private static var AccountName:String = "";
      
      private static var InnerListItems:Array = null;
      
      private static var initialized:Boolean = false;
      
      private static var errorMessage_tf:TextField;
      
      private static var errorMessageLastDisplay:Number;
      
      private static var lastErrorUID:uint = 0;
      
      private static var loadouts_tf:TextField;
       
      
      public function RadialMenuLoadoutConfig()
      {
         super();
      }
      
      public static function get() : *
      {
         if(config == null)
         {
            return {};
         }
         return config;
      }
      
      public static function toJSON(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function init(topLevel:*) : void
      {
         radialMenu = topLevel;
         errorMessage_tf = createTextField();
         loadouts_tf = createTextField();
         loadConfig();
         PlayerInventoryData = BSUIDataManager.GetDataFromClient("PlayerInventoryData").data;
         BSUIDataManager.Subscribe("CharacterInfoData",onCharacterInfoDataUpdate);
         BSUIDataManager.Subscribe("AccountInfoData",onAccountInfoUpdate);
         BSUIDataManager.Subscribe("RadialMenuListData",onRadialMenuListUpdate);
      }
      
      private static function onAccountInfoUpdate(param1:FromClientDataEvent) : void
      {
         AccountName = param1.data.name;
         listLoadouts();
      }
      
      private static function onCharacterInfoDataUpdate(param1:FromClientDataEvent) : void
      {
         CharacterName = param1.data.name;
         listLoadouts();
      }
      
      private static function onRadialMenuListUpdate(param1:FromClientDataEvent) : void
      {
         if(InnerListItems == null)
         {
            InnerListItems = [];
            return;
         }
         InnerListItems = param1.data.items;
         listLoadouts();
      }
      
      private static function createTextField() : TextField
      {
         var tf:TextField = new TextField();
         tf.x = -940;
         tf.y = -540;
         tf.width = 800;
         tf.height = 800;
         tf.wordWrap = true;
         tf.multiline = true;
         var font:TextFormat = new TextFormat("$MAIN_Font",18,16777215);
         tf.defaultTextFormat = font;
         tf.setTextFormat(font);
         tf.selectable = false;
         tf.mouseWheelEnabled = false;
         tf.mouseEnabled = false;
         tf.visible = true;
         tf.filters = [new DropShadowFilter(2,45,0,1,1,1,1,BitmapFilterQuality.HIGH)];
         radialMenu.addChild(tf);
         return tf;
      }
      
      public static function displayLoadout(param1:*, clear:Boolean = false) : void
      {
         if(param1 is String)
         {
            var str:String = param1;
         }
         else
         {
            str = toJSON(param1);
         }
         if(clear)
         {
            GlobalFunc.SetText(loadouts_tf,str);
         }
         else
         {
            GlobalFunc.SetText(loadouts_tf,loadouts_tf.text + "\n" + str);
         }
      }
      
      public static function displayError(param1:*, clear:Boolean = false) : void
      {
         var str:String;
         if(clear)
         {
            errorMessage_tf.text = "";
         }
         if(param1 is String)
         {
            str = param1;
         }
         else
         {
            str = toJSON(param1);
         }
         GlobalFunc.SetText(errorMessage_tf,errorMessage_tf.text + "\n" + str);
         errorMessage_tf.scrollV = errorMessage_tf.maxScrollV;
         errorMessageLastDisplay = getTimer();
         if(lastErrorUID != 0)
         {
            clearTimeout(lastErrorUID);
         }
         lastErrorUID = setTimeout(function():void
         {
            if(getTimer() - errorMessageLastDisplay > 4750)
            {
               errorMessage_tf.text = "";
            }
         },5000);
      }
      
      private static function loadConfig() : void
      {
         var loaderComplete:Function = null;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            loaderComplete = function(param1:Event):void
            {
               var json:Object;
               var errorCode:String = "loaderComplete";
               try
               {
                  errorCode = "JSONDecoder";
                  json = new JSONDecoder(loader.data,true).getValue();
                  errorCode = "initializeConfig";
                  initializeConfig(json);
                  errorCode = "onShowInventory";
                  radialMenu.onShowInventory();
                  errorCode = "onSlotItemCancel";
                  radialMenu.onSlotItemCancel();
                  if(DEBUG)
                  {
                     displayError("Config file loaded!");
                  }
                  errorCode = "listLoadouts";
                  listLoadouts();
               }
               catch(e:*)
               {
                  displayError(FULL_MOD_NAME + " Error initializing config! " + errorCode + ": " + e);
               }
               loader.removeEventListener(Event.COMPLETE,loaderComplete);
            };
            url = new URLRequest(FILE_NAME);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete);
         }
         catch(e:*)
         {
            displayError(FULL_MOD_NAME + " Error loading config! " + e);
         }
      }
      
      private static function initializeConfig(data:* = null) : void
      {
         if(data == null)
         {
            data = {};
         }
         DEBUG = data.debug;
         DEBUG_SELECTION = data.debugSelection;
         if(data.loadouts == null)
         {
            data.loadouts = [];
         }
         else
         {
            var i:int = 0;
            while(i < data.loadouts.length)
            {
               var loadout:Object = data.loadouts[i];
               if(loadout != null)
               {
                  data.loadouts[i].hotkey = data.loadouts[i].hotkey != null && !isNaN(data.loadouts[i].hotkey) ? Number(data.loadouts[i].hotkey) : 0;
                  data.loadouts[i].name = data.loadouts[i].name == null ? "Loadout " + i : data.loadouts[i].name;
                  data.loadouts[i].account = data.loadouts[i].account == null ? [] : [].concat(data.loadouts[i].account);
                  data.loadouts[i].character = data.loadouts[i].character == null ? [] : [].concat(data.loadouts[i].character);
               }
               i++;
            }
         }
         loadouts_tf.x = data.x != null && !isNaN(data.x) ? data.x : -500;
         loadouts_tf.y = data.y != null && !isNaN(data.y) ? data.y : -200;
         var font:TextFormat = loadouts_tf.getTextFormat();
         font.size = data.textSize != null && !isNaN(data.textSize) ? data.textSize : 20;
         font.align = data.textAlign != null && data.textAlign is String ? data.textAlign.toLowerCase() : "left";
         font.font = data.textFont != null && data.textFont is String ? data.textFont : "$MAIN_Font_Bold";
         loadouts_tf.defaultTextFormat = font;
         loadouts_tf.setTextFormat(font);
         data.formatEquipped = data.formatEquipped != null && data.formatEquipped is String ? data.formatEquipped : "[E]\t{key}) {name}";
         data.formatUnequipped = data.formatUnequipped != null && data.formatUnequipped is String ? data.formatUnequipped : "\t{key}) {name}";
         data.colorEquipped = data.colorEquipped != null && !isNaN(data.colorEquipped) ? data.colorEquipped : 5166368;
         data.colorUnequipped = data.colorUnequipped != null && !isNaN(data.colorUnequipped) ? data.colorUnequipped : 16777215;
         config = data;
      }
      
      private static function indexOfCaseInsensitiveString(arr:Array, searchingFor:String, fromIndex:uint = 0) : int
      {
         var lowercaseSearchString:String = searchingFor.toLowerCase();
         var len:uint = arr.length;
         var i:uint = fromIndex;
         while(i < len)
         {
            var element:* = arr[i];
            if(element is String && lowercaseSearchString.indexOf(element.toLowerCase()) != -1)
            {
               return i;
            }
            i++;
         }
         return -1;
      }
      
      private static function slotItem(item:Object) : void
      {
         BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_SLOT_ITEM,item));
      }
      
      private static function isValidCharacterAccount(loadout:Object) : Boolean
      {
         if(loadout.character != null && loadout.character.length > 0 && loadout.character.indexOf(CharacterName) == -1)
         {
            return false;
         }
         if(loadout.account != null && loadout.account.length > 0 && loadout.account.indexOf(AccountName) == -1)
         {
            return false;
         }
         return true;
      }
      
      private static function isEquippedLoadout(loadout:Object) : Boolean
      {
         if(InnerListItems == null || InnerListItems.length != 12)
         {
            return false;
         }
         var isEquipped:Boolean = true;
         var i:int = 0;
         while(i < 12)
         {
            var slotKey:String = String(i + 1);
            if(loadout[slotKey] != null)
            {
               var searchFor:String = loadout[slotKey].toLowerCase();
               var lowercaseName:String = InnerListItems[i].name.toLowerCase();
               if(lowercaseName.indexOf(searchFor) == -1)
               {
                  isEquipped = false;
                  break;
               }
            }
            i++;
         }
         return isEquipped;
      }
      
      public static function listLoadouts(force:Boolean = false) : void
      {
         if(initialized && !force)
         {
            return;
         }
         if(config == null || AccountName == "" || CharacterName == "" || InnerListItems == null || InnerListItems.length == 0)
         {
            return;
         }
         loadouts_tf.text = "";
         initialized = true;
         var applyFormats:Array = [];
         var formatEquipped:* = null;
         if(config.colorEquipped != null && !isNaN(config.colorEquipped))
         {
            formatEquipped = new TextFormat();
            formatEquipped.color = config.colorEquipped;
         }
         var formatUnequipped:* = null;
         if(config.colorUnequipped != null && !isNaN(config.colorUnequipped))
         {
            formatUnequipped = new TextFormat();
            formatUnequipped.color = config.colorUnequipped;
         }
         var currentLineStartIndex:int = 0;
         i = 0;
         while(i < config.loadouts.length)
         {
            currentLineStartIndex = int(loadouts_tf.text.length);
            if(config.loadouts[i] != null)
            {
               if(isValidCharacterAccount(config.loadouts[i]))
               {
                  if(isEquippedLoadout(config.loadouts[i]))
                  {
                     displayLoadout(" " + config.formatEquipped.replace("{name}",config.loadouts[i].name).replace("{key}",getButtonKey(config.loadouts[i].hotkey)));
                     if(formatEquipped != null)
                     {
                        applyFormats.push({
                           "format":formatEquipped,
                           "startIndex":currentLineStartIndex + 1,
                           "endIndex":loadouts_tf.text.length
                        });
                     }
                  }
                  else
                  {
                     displayLoadout(" " + config.formatUnequipped.replace("{name}",config.loadouts[i].name).replace("{key}",getButtonKey(config.loadouts[i].hotkey)));
                     if(formatUnequipped != null)
                     {
                        applyFormats.push({
                           "format":formatUnequipped,
                           "startIndex":currentLineStartIndex + 1,
                           "endIndex":loadouts_tf.text.length
                        });
                     }
                  }
               }
            }
            i++;
         }
         i = 0;
         while(i < applyFormats.length)
         {
            loadouts_tf.setTextFormat(applyFormats[i].format,applyFormats[i].startIndex,applyFormats[i].endIndex);
            i++;
         }
         loadouts_tf.visible = radialMenu.selectedMenuIndex == 0;
      }
      
      public static function onKeyUp(event:KeyboardEvent) : void
      {
         var i:int;
         var loadout:*;
         var loadoutNames:Array;
         var loadoutSlots:Object;
         var slotId:int;
         var itemId:int;
         var itemCount:int;
         var foundItemId:int;
         var loadoutName:String;
         var st:String;
         var radialList:*;
         var radialExpandedList:*;
         var slotKey:String;
         var item:Object;
         var errorCode:String = "keyUp";
         try
         {
            if(DEBUG)
            {
               errorCode = "DEBUG";
               if(event.keyCode == 122)
               {
                  listLoadouts(true);
               }
               else if(event.keyCode == 123)
               {
                  errorCode = "DEBUG radialList";
                  radialList = BSUIDataManager.GetDataFromClient("RadialMenuListData").data;
                  errorCode = "DEBUG radialExpandedList";
                  radialExpandedList = BSUIDataManager.GetDataFromClient("RadialMenuExpandedListData").data;
                  errorCode = "DEBUG list 1 display";
                  if(config.debugRadialMenuListData)
                  {
                     displayError("RadialMenuListData:\n" + toJSON(radialList));
                  }
                  errorCode = "DEBUG list 2 display";
                  if(config.debugRadialMenuExpandedListData)
                  {
                     displayError("RadialMenuExpandedListData:\n" + toJSON(radialExpandedList));
                  }
               }
            }
            errorCode = "return";
            if(config == null || PlayerInventoryData == null || PlayerInventoryData.InventoryList == null || PlayerInventoryData.InventoryList.length == 0)
            {
               return;
            }
            errorCode = "loadouts";
            i = 0;
            while(i < config.loadouts.length)
            {
               errorCode = "loadout " + i;
               loadout = config.loadouts[i];
               if(Boolean(loadout) && loadout.hotkey == event.keyCode && isValidCharacterAccount(loadout))
               {
                  errorCode = "key detected " + loadout.hotkey;
                  loadoutNames = [];
                  loadoutSlots = {};
                  errorCode = "slots 13 " + i;
                  slotId = 1;
                  while(slotId < 13)
                  {
                     slotKey = String(slotId);
                     if(loadout[slotKey] != null)
                     {
                        loadoutNames.push(loadout[slotKey]);
                        loadoutSlots[loadout[slotKey]] = {"slotId":slotId - 1};
                     }
                     slotId++;
                  }
                  errorCode = "items len " + i;
                  itemId = 0;
                  itemCount = int(PlayerInventoryData.InventoryList.length);
                  errorCode = "find items " + i;
                  while(itemId < itemCount)
                  {
                     item = PlayerInventoryData.InventoryList[itemId];
                     if(item.filterFlag & 0x7C)
                     {
                        foundItemId = indexOfCaseInsensitiveString(loadoutNames,item.text);
                        if(foundItemId != -1)
                        {
                           errorCode = "found item " + i + " " + foundItemId;
                           loadoutName = loadoutNames[foundItemId];
                           errorCode = "append serverHandleId " + i + " " + foundItemId;
                           if(loadoutSlots[loadoutName] != null)
                           {
                              loadoutSlots[loadoutName].serverHandleId = item.serverHandleId;
                              loadoutSlots[loadoutName].text = item.text;
                           }
                           errorCode = "splice " + i + " " + foundItemId;
                           loadoutNames.splice(foundItemId,1);
                           if(loadoutNames.length == 0)
                           {
                              break;
                           }
                        }
                     }
                     itemId++;
                  }
                  errorCode = "slotting loadout";
                  st = "Slotting loadout: " + loadout.name + "\n";
                  for(slot in loadoutSlots)
                  {
                     errorCode = "slotting id";
                     st += loadoutSlots[slot].slotId + 1 + " | " + (loadoutSlots[slot].text || "") + "\n";
                     if(loadoutSlots[slot].serverHandleId != null && loadoutSlots[slot].text != InnerListItems[loadoutSlots[slot].slotId].name)
                     {
                        errorCode = "slotting item " + slot;
                        slotItem(loadoutSlots[slot]);
                     }
                  }
                  if(DEBUG)
                  {
                     displayError(st);
                  }
                  setTimeout(listLoadouts,100,true);
                  break;
               }
               i++;
            }
         }
         catch(e:*)
         {
            displayError("Error: " + errorCode + " : " + e);
         }
      }
      
      public static function getButtonKey(keyCode:uint) : String
      {
         switch(keyCode)
         {
            case 9:
               return "Tab";
            case 13:
               return "Enter";
            case 16:
               return "Shift";
            case 17:
               return "Ctrl";
            case 18:
               return "Alt";
            case 19:
               return "Pause";
            case 20:
               return "CapLk";
            case 27:
               return "Esc";
            case 33:
               return "PgUp";
            case 34:
               return "PgDn";
            case 35:
               return "End";
            case 36:
               return "Home";
            case 37:
               return "Left";
            case 38:
               return "Up";
            case 39:
               return "Right";
            case 40:
               return "Down";
            case 45:
               return "Ins";
            case 46:
               return "Del";
            case 93:
               return "Sel";
            case 96:
               return "N0";
            case 97:
               return "N1";
            case 98:
               return "N2";
            case 99:
               return "N3";
            case 100:
               return "N4";
            case 101:
               return "N5";
            case 102:
               return "N6";
            case 103:
               return "N7";
            case 104:
               return "N8";
            case 105:
               return "N9";
            case 106:
               return "N*";
            case 107:
               return "N+";
            case 109:
               return "N-";
            case 110:
               return "N.";
            case 111:
               return "N/";
            case 112:
               return "F1";
            case 113:
               return "F2";
            case 114:
               return "F3";
            case 115:
               return "F4";
            case 116:
               return "F5";
            case 117:
               return "F6";
            case 118:
               return "F7";
            case 119:
               return "F8";
            case 120:
               return "F9";
            case 121:
               return "F10";
            case 122:
               return "F11";
            case 123:
               return "F12";
            case 144:
               return "NumLk";
            case 145:
               return "ScrLk";
            default:
               return String.fromCharCode(keyCode);
         }
      }
   }
}
