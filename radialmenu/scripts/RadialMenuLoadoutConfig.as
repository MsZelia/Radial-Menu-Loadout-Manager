package
{
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.Events.CustomEvent;
   import Shared.AS3.Events.PlatformChangeEvent;
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
      
      private static const MOD_VERSION:String = "1.0.3";
      
      private static const FULL_MOD_NAME:String = "[" + MOD_NAME + " " + MOD_VERSION + "]";
      
      private static const FILE_NAME:String = "../RadialMenuLoadoutConfig.json";
      
      private static const EVENT_SLOT_ITEM:String = "Radial::SlotItem";
      
      public static var DEBUG:Boolean = false;
      
      public static var DEBUG_SELECTION:Boolean = false;
      
      public static var DEBUG_EVENTS:Boolean = false;
      
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
      
      private static var selectedLoadoutId:int = 0;
      
      private static var validLoadouts:Array = [];
      
      private static var errorCode:String;
       
      
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
               errorCode = "loaderComplete";
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
         DEBUG_EVENTS = data.debugUserEvents;
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
                  var slotId:int = 1;
                  while(slotId < 13)
                  {
                     var slotKey:String = String(slotId);
                     if(data.loadouts[i][slotKey] != null)
                     {
                        data.loadouts[i][slotKey] = [].concat(data.loadouts[i][slotKey]);
                     }
                     slotId++;
                  }
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
         data.formatGamepadButtonInfo = data.formatGamepadButtonInfo != null && data.formatGamepadButtonInfo is String ? data.formatGamepadButtonInfo : "\n Left/Right) Select loadout\n Start) Equip: {selectedLoadout}";
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
            errorCode = "isEQ " + i;
            var slotKey:String = String(i + 1);
            if(loadout[slotKey] != null)
            {
               errorCode = "isEQ " + i + " not null";
               var foundInSlot:Boolean = loadout[slotKey].length == 0;
               var j:int = 0;
               errorCode = "isEQ " + i + " loop";
               while(j < loadout[slotKey].length)
               {
                  var searchFor:String = loadout[slotKey][j].toLowerCase();
                  var lowercaseName:String = InnerListItems[i].name.toLowerCase();
                  if(lowercaseName.indexOf(searchFor) != -1)
                  {
                     foundInSlot = true;
                     break;
                  }
                  j++;
               }
               if(!foundInSlot)
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
         var applyFormats:Array;
         var formatEquipped:*;
         var formatUnequipped:*;
         var currentLineStartIndex:int;
         try
         {
            if(initialized && !force)
            {
               return;
            }
            if(config == null || AccountName == "" || CharacterName == "" || InnerListItems == null || InnerListItems.length == 0)
            {
               return;
            }
            errorCode = "init";
            loadouts_tf.text = "";
            initialized = true;
            applyFormats = [];
            formatEquipped = null;
            errorCode = "color formats";
            if(config.colorEquipped != null && !isNaN(config.colorEquipped))
            {
               formatEquipped = new TextFormat();
               formatEquipped.color = config.colorEquipped;
            }
            formatUnequipped = null;
            if(config.colorUnequipped != null && !isNaN(config.colorUnequipped))
            {
               formatUnequipped = new TextFormat();
               formatUnequipped.color = config.colorUnequipped;
            }
            errorCode = "apply formats";
            currentLineStartIndex = 0;
            validLoadouts = [];
            i = 0;
            while(i < config.loadouts.length)
            {
               currentLineStartIndex = int(loadouts_tf.text.length);
               if(config.loadouts[i] != null)
               {
                  errorCode = "isValidCharacterAccount";
                  if(isValidCharacterAccount(config.loadouts[i]))
                  {
                     errorCode = "isEquippedLoadout";
                     if(isEquippedLoadout(config.loadouts[i]))
                     {
                        errorCode = "display loadout EQ";
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
                        errorCode = "display loadout notEQ";
                        displayLoadout(" " + config.formatUnequipped.replace("{name}",config.loadouts[i].name).replace("{key}",getButtonKey(config.loadouts[i].hotkey)));
                        if(formatUnequipped != null)
                        {
                           applyFormats.push({
                              "format":formatUnequipped,
                              "startIndex":currentLineStartIndex + 1,
                              "endIndex":loadouts_tf.text.length
                           });
                        }
                        validLoadouts.push({
                           "id":i,
                           "name":config.loadouts[i].name
                        });
                     }
                  }
               }
               i++;
            }
            errorCode = "controller keybinds";
            if(radialMenu.uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
            {
               if(selectedLoadoutId < 0)
               {
                  selectedLoadoutId = validLoadouts.length - 1;
               }
               else if(selectedLoadoutId >= validLoadouts.length)
               {
                  selectedLoadoutId = 0;
               }
               if(selectedLoadoutId >= 0 && selectedLoadoutId < validLoadouts.length)
               {
                  displayLoadout(config.formatGamepadButtonInfo.replace("{selectedLoadout}",validLoadouts[selectedLoadoutId].name));
               }
               else
               {
                  displayLoadout(config.formatGamepadButtonInfo.replace("{selectedLoadout}","null"));
               }
            }
            errorCode = "apply formats";
            i = 0;
            while(i < applyFormats.length)
            {
               loadouts_tf.setTextFormat(applyFormats[i].format,applyFormats[i].startIndex,applyFormats[i].endIndex);
               i++;
            }
            loadouts_tf.visible = radialMenu.selectedMenuIndex == 0;
         }
         catch(e:*)
         {
            displayError("Error listLoadouts: " + errorCode + " : " + e);
         }
      }
      
      private static function slotItem(item:Object) : void
      {
         BSUIDataManager.dispatchEvent(new CustomEvent(EVENT_SLOT_ITEM,item));
      }
      
      private static function slotLoadout(loadout:Object) : void
      {
         errorCode = "key detected " + loadout.hotkey;
         var loadoutSlots:Object = {};
         errorCode = "find matches";
         var matches:Array = findMatches(loadout,PlayerInventoryData.InventoryList);
         errorCode = "append slotIds";
         var slotId:int = 0;
         while(slotId < 12)
         {
            var slotKey:String = String(slotId + 1);
            errorCode = "loadout " + slotId;
            if(loadout[slotKey] != null && loadout[slotKey].length > 0)
            {
               errorCode = "matches " + slotId;
               if(matches != null && matches[slotId].length > 0)
               {
                  errorCode = "indexItemNames " + slotId;
                  var indexItemNames:int = 0;
                  while(indexItemNames < matches[slotId].length)
                  {
                     errorCode = "match " + slotId;
                     if(matches[slotId][indexItemNames].length > 0)
                     {
                        errorCode = "found match " + slotId + " " + indexItemNames;
                        var match:Object = matches[slotId][indexItemNames][0];
                        loadoutSlots[match.text] = {
                           "slotId":slotId,
                           "serverHandleID":match.serverHandleID,
                           "text":match.text
                        };
                        break;
                     }
                     indexItemNames++;
                  }
               }
            }
            slotId++;
         }
         errorCode = "slotting loadout";
         var st:String = "Slotting loadout: " + loadout.name + "\n";
         for(slot in loadoutSlots)
         {
            errorCode = "slotting id";
            st += loadoutSlots[slot].slotId + 1 + " | " + (loadoutSlots[slot].text || "") + "\n";
            if(loadoutSlots[slot].serverHandleID != null && loadoutSlots[slot].text != InnerListItems[loadoutSlots[slot].slotId].name)
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
      }
      
      public static function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         if(DEBUG_EVENTS)
         {
            displayError("event: " + param1 + ", " + param2 + " - platform: " + radialMenu.uiPlatform);
         }
         if(!param2 && config != null && config.loadouts != null)
         {
            if(radialMenu.uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
            {
               if(param1 == "Map")
               {
                  if(DEBUG)
                  {
                     displayError("Gamepad: Slot loadout");
                  }
                  if(selectedLoadoutId < validLoadouts.length && validLoadouts[selectedLoadoutId] != null && validLoadouts[selectedLoadoutId].id < config.loadouts.length)
                  {
                     slotLoadout(config.loadouts[validLoadouts[selectedLoadoutId].id]);
                  }
               }
               else if(param1 == "Left")
               {
                  if(DEBUG)
                  {
                     displayError("Gamepad: Prev loadout");
                  }
                  selectedLoadoutId--;
                  listLoadouts(true);
               }
               else if(param1 == "Right")
               {
                  if(DEBUG)
                  {
                     displayError("Gamepad: Next loadout");
                  }
                  selectedLoadoutId++;
                  listLoadouts(true);
               }
            }
         }
         return false;
      }
      
      public static function onKeyUp(event:KeyboardEvent) : void
      {
         var i:int;
         var loadout:*;
         var radialList:*;
         var radialExpandedList:*;
         try
         {
            errorCode = "keyUp";
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
                  slotLoadout(loadout);
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
      
      private static function findMatches(loadout:Object, items:Array) : Array
      {
         var matches:Array = new Array(12);
         var loadoutNames:Array = new Array(12);
         var j:int = 0;
         var i:int = 0;
         while(i < 12)
         {
            var slotKey:String = String(i + 1);
            if(loadout[slotKey] != null)
            {
               loadoutNames[i] = loadout[slotKey];
               matches[i] = new Array(loadoutNames[i].length);
               j = 0;
               while(j < loadoutNames[i].length)
               {
                  matches[i][j] = new Array();
                  j++;
               }
            }
            else
            {
               matches[i] = new Array();
               loadoutNames[i] = new Array();
            }
            i++;
         }
         i = 0;
         while(i < items.length)
         {
            var item:Object = items[i];
            if(item.filterFlag & 0x7C)
            {
               var itemName:String = item.text.toLowerCase();
               j = 0;
               while(j < 12)
               {
                  var foundItemId:int = indexOfCaseInsensitiveString(loadoutNames[j],itemName);
                  if(foundItemId != -1)
                  {
                     matches[j][foundItemId].push({
                        "serverHandleID":item.serverHandleID,
                        "text":item.text
                     });
                  }
                  j++;
               }
            }
            i++;
         }
         return matches;
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
