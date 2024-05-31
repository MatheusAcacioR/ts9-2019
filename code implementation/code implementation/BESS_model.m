function [PESS_Estimated,SOC_Estimated]=BESS_model(t,net_PESS,net_SOC,P_ESS_Request_W_subset,P_ESS_W_subset,SOC_subset,PESS_Estimated,SOC_Estimated) 

% Implementação completa - SOC + P_ESS

  if t < 3
        InputNeural_SOC = [ P_ESS_W_subset(t)/13800.0 ; SOC_subset(t)/100.0];
  else
        InputNeural_SOC = [ PESS_Estimated(t-2)/13800.0; SOC_Estimated(t-1)];
        %input_set = [(Power_Request(t))/13800.0 SOC(t)/100.0 P_ESS(t)/13800.0]';
  end  
    
  %InputNeural_SOC = [P_ESS(t)/13800.0 SOC(t)/100.0]';
  
  SOC_Estimated(t) = net_SOC(InputNeural_SOC);
  
  if t >= 2
      if t == 2
          InputNeural_PESS = [P_ESS_Request_W_subset(t)/13800.0; SOC_Estimated(t-1); P_ESS_W_subset(t-1)/13800.0];
      else
          InputNeural_PESS = [P_ESS_Request_W_subset(t)/13800.0; SOC_Estimated(t-1); PESS_Estimated(t-2)/13800.0];
      end
      
      PESS_Estimated(t-1) = net_PESS(InputNeural_PESS)*13800.0;
      
  else
     PESS_Estimated(t)=P_ESS_W_subset(t);
      
  end
  
end     


