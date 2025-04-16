package Shared.AS3
{
   import flash.display.MovieClip;
   
   public class BCBasicMenuItem extends MovieClip
   {
       
      
      public var Sizer_mc:MovieClip;
      
      public var HitArea_mc:MovieClip;
      
      public var Text_mc:MovieClip;
      
      public var Image_mc:MovieClip;
      
      private var m_Selected:Boolean = false;
      
      private var m_Disabled:Boolean = false;
      
      private var m_Text:String;
      
      private var m_Index:uint = 0;
      
      public function BCBasicMenuItem()
      {
         super();
         if(this.HitArea_mc != null)
         {
            this.hitArea = this.HitArea_mc;
         }
         else if(this.Sizer_mc != null)
         {
            this.hitArea = this.Sizer_mc;
         }
      }
      
      public function set text(param1:String) : void
      {
         this.m_Text = param1;
         if(this.Text_mc != null)
         {
            this.Text_mc.Text_tf.text = this.m_Text;
         }
      }
      
      public function get text() : String
      {
         return this.m_Text;
      }
      
      private function updateState() : void
      {
         if(this.m_Disabled)
         {
            if(this.m_Selected)
            {
               gotoAndPlay("rollOnDisabled");
            }
            else
            {
               gotoAndPlay("offDisabled");
            }
         }
         else if(this.m_Selected)
         {
            gotoAndPlay("rollOn");
         }
         else
         {
            gotoAndPlay("off");
         }
      }
      
      public function set disabled(param1:Boolean) : void
      {
         if(param1 != this.m_Disabled)
         {
            this.m_Disabled = param1;
            this.updateState();
         }
      }
      
      public function get disabled() : Boolean
      {
         return this.m_Disabled;
      }
      
      public function set index(param1:uint) : void
      {
         this.m_Index = param1;
      }
      
      public function get index() : uint
      {
         return this.m_Index;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(param1 != this.m_Selected)
         {
            this.m_Selected = param1;
            this.updateState();
         }
      }
   }
}
