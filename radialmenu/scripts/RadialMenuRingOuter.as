package
{
   import Shared.AS3.Data.BSUIDataManager;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol539")]
   public class RadialMenuRingOuter extends RadialMenuRing
   {
       
      
      public function RadialMenuRingOuter()
      {
         super();
         addFrameScript(5,this.frame6,11,this.frame12);
         ENTRY_MAX = 16;
         CreateEntries();
         BSUIDataManager.Subscribe("RadialMenuExpandedListData",onListUpdate);
      }
      
      override public function open() : *
      {
         super.open();
      }
      
      override public function close() : *
      {
         super.close();
      }
      
      internal function frame6() : *
      {
         stop();
      }
      
      internal function frame12() : *
      {
         stop();
      }
   }
}
