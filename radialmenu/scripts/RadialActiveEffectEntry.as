package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol453")]
   public class RadialActiveEffectEntry extends MovieClip
   {
       
      
      public var Icon_mc:MovieClip;
      
      public var EffectName_mc:MovieClip;
      
      public function RadialActiveEffectEntry()
      {
         super();
      }
      
      public function UpdateEffectEntry(param1:Object) : *
      {
         this.EffectName_mc.title_tf.text = param1.effectName;
         this.Icon_mc.gotoAndStop(param1.effectIcon);
      }
   }
}
