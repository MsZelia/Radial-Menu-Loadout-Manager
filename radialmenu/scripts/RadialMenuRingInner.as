package
{
   import Shared.AS3.Data.BSUIDataManager;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol494")]
   public class RadialMenuRingInner extends RadialMenuRing
   {
      
      private var m_Expanded:Boolean = false;
      
      public function RadialMenuRingInner()
      {
         super();
         addFrameScript(5,this.frame6,11,this.frame12);
         CreateEntries();
         BSUIDataManager.Subscribe("RadialMenuListData",onListUpdate);
      }
      
      public function get expanded() : Boolean
      {
         return this.m_Expanded;
      }
      
      public function set expanded(param1:Boolean) : *
      {
         this.m_Expanded = param1;
         if(m_SelectedEntry != null)
         {
            (m_SelectedEntry as RadialMenuEntryInner).expanded = this.m_Expanded;
         }
      }
      
      override protected function setSelectedIndex(param1:int) : void
      {
         super.setSelectedIndex(param1);
         if(m_SelectedEntry != null)
         {
            (m_SelectedEntry as RadialMenuEntryInner).expanded = this.m_Expanded;
         }
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

