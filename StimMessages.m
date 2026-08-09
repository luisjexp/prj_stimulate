classdef StimMessages
   properties (Constant)
     
      view_waitScreen       = 'view_waitScreen';
      view_whiteScreen      = 'view_whiteScreen';
      view_grayScreen       = 'view_grayScreen';
      view_dotMovie         = 'view_dotMovie';
      
      set_randDotDirection  = 'set_randDotDirection';
      set_specDotDirection  = 'set_specDotDirection';
      set_coherence         = 'set_coherence';
      set_lifeTime          = 'set_lifeTime';
      set_newMessage        = 'set_newMessage'
      
      get_coherence         = 'get_coherence';
      get_lifeTime          = 'get_lifeTime';
      get_currentDirection  = 'get_currentDirection';
      
      confirmConnection     = 'confirmConnection';
      shutDown              = 'shutDown';       
   end
   
   methods (Static)
       function s = getAllValidMessages
           s = properties(StimMessages)';
       end
   end
    
    
end