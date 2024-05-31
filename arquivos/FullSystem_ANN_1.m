% Implementação completa - SOC + P_ESS


clear all 
close all

load Neural_SOC_dataset6.mat
load Neural_PESS_dataset6.mat 

name2 = 'Testing_dataset6(24_days_subset).mat';
load(name2);

lenTst = size(P_ESS_Request_W_subset,2);
P_ESS_Request_W_subset = P_ESS_Request_W_subset(1:2:lenTst);
SOC_subset = SOC_subset(1:2:lenTst);
P_ESS_W_subset = P_ESS_W_subset(1:2:lenTst);
lenTst = round(lenTst/2);


len = size(SOC_subset,2);
k = 1; 
SOC_Estimated = ones(1,len-1);
for t = 1:len - 1
  
  
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
      k = k + 1;
  end
  
end     

SOC_Estimated = round(SOC_Estimated*100);

figure
plot(SOC_Estimated);
hold
plot(SOC_subset(2:len),'r');
legend('SOC Est','SOC Original');

figure
plot(PESS_Estimated);
hold
plot(P_ESS_W_subset(3:len));
legend('PESS Est','PESS Original')

B = 1/60*ones(60,1);
%P_ESS_filtered = filter(B,1,P_ESS_W_subset)';
SOC_Estimated = interp(SOC_Estimated,2);
SOC_subset = interp(SOC_subset,2);

SOC_Estimated_filtered = filter(B,1,SOC_Estimated); 
SOC_subset_filtered = filter(B,1,SOC_subset); 
error_SOC = SOC_Estimated_filtered-SOC_subset_filtered(3:len*2); 
perfError_soc = mae(error_SOC);
figure
plot(SOC_Estimated_filtered);
hold
plot(SOC_subset_filtered(3:len*2));
legend('SOC Est (average)','SOC Original (average)')
str = sprintf('ErrorSOC (MAE) = %f',perfError_soc);
text(1000,50,str);


PESS_Estimated = interp(PESS_Estimated,2);
P_ESS_W_subset = interp(P_ESS_W_subset,2);

PESS_Estimated_filtered = filter(B,1,PESS_Estimated); 
P_ESS_W_subset_filtered = filter(B,1,P_ESS_W_subset); 

error_PESS = PESS_Estimated_filtered-P_ESS_W_subset_filtered(5:len*2); 
perfError_pess = mae(error_PESS); 
figure
plot(PESS_Estimated_filtered);
hold
plot(P_ESS_W_subset_filtered(3:len*2));
legend('PESS Est (average)','PESS Original (average)')
str = sprintf('ErrorPESS (MAE) = %f',perfError_pess);
text(500,7500,str);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% B = 1/60*ones(60,1);
% P_ESS_filtered = filter(B,1,P_ESS_W_subset)';

