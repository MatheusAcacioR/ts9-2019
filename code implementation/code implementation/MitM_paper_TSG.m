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
PESS_est = zeros(1,len-1);
PESS_exp = zeros(1,len-1);
PESS = zeros(1,len-1);
SOC_est = ones(1,len-1);
SOC_exp = ones(1,len-1);
SOC = ones(1,len-1);

% Define the attack signal
    delta_P_Req = zeros(1,len-1); % without Attack signal

    % Attack 1 - during the discharge
    %delta_P_Req(6200:6300)=-12000;  % set the interference
    %delta_P_Req(6600:6700)=12000;  % set the interference
    
    % Attack 2 - during the charge
    %delta_P_Req(4000:4500)=-10000;  % set the interference
    
    % Attack 3 - discharge and charge (expend lifecycle)
    %delta_P_Req(4800:5300)=13300/500*(0:-1:-500);  % set the interference
    %delta_P_Req(5301:5801)=13300/500*(0:1:500);  % set the interference
    %delta_P_Req(4800:5801)=delta_P_Req(4800:5801)-P_ESS_Request_W_subset(4800:5801);

    % Attack 4 - discharge and charge (expend lifecycle) - spaced
%     delta_P_Req(4500:5000)=13300/500*(0:-1:-500);  % set the interference
%     delta_P_Req(5001:5100)=-13300;  % set the interference
%     delta_P_Req(5100:5600)=13300/500*(0:1:500);  % set the interference
%     delta_P_Req(5601:5700)=13300;  % set the interference
%     delta_P_Req(4500:5700)=delta_P_Req(4500:5700)-P_ESS_Request_W_subset(4500:5700);

    % Attack 5 - fast discharge and charge (expend lifecycle)
%     delta_P_Req(4500:4800)=13800/300*(0:-1:-300);  % set the interference
%     delta_P_Req(4801:5100)=-13800;  % set the interference
%     %delta_P_Req(5100:5200)=13800/100*(0:1:100);  % set the interference
%     %delta_P_Req(5100:5120)=0;  % set the interference
%     delta_P_Req(5101:5700)=13800;  % set the interference
%     delta_P_Req(4500:5700)=delta_P_Req(4500:5700)-P_ESS_Request_W_subset(4500:5700);
    
    
    % Attack 6 - pulse discharge and charge (expend lifecycle)
%     delta_P_Req(4500:4950)=-13800;  % set the interference
%     %delta_P_Req(5100:5200)=13800/100*(0:1:100);  % set the interference
%     %delta_P_Req(5100:5120)=0;  % set the interference
%     delta_P_Req(4951:5600)=13800;  % set the interference
%     delta_P_Req(4500:5600)=delta_P_Req(4500:5600)-P_ESS_Request_W_subset(4500:5600);
    
    
    % Attack 7 - pulse discharge and charge (expend lifecycle) - spaced
%     delta_P_Req(4500:4950)=-13800;  % set the interference
%     delta_P_Req(5051:5700)=13800;  % set the interference
%     delta_P_Req(4500:5700)=delta_P_Req(4500:5700)-P_ESS_Request_W_subset(4500:5700);

    % Attack 8 - discharge and charge sequence (expend lifecycle) - spaced
    auto_delta_P_Req_flag=1; % set the auto auto_delta_P_Req computation on
    charge_flag=1;
    discharge_flag=0;

for t = 1:len - 1
  
    
  % Add the attack signal
  P_Req_line(t)=P_ESS_Request_W_subset(t)+delta_P_Req(t);
    
  % Compute M_exp
  [PESS_exp,SOC_exp]=BESS_model(t,net_PESS,net_SOC,P_ESS_Request_W_subset,P_ESS_W_subset,SOC_subset,PESS_exp,SOC_exp);
  M_exp=[PESS_exp;SOC_exp];
  
  % Compute M_est
  [PESS_est,SOC_est]=BESS_model(t,net_PESS,net_SOC,P_Req_line,P_ESS_W_subset,SOC_subset,PESS_est,SOC_est);
  M_est=[PESS_est;SOC_est];
  
  % Compute M
  [PESS,SOC]=BESS_model(t,net_PESS,net_SOC,P_Req_line,P_ESS_W_subset,SOC_subset,PESS,SOC);
  M=[PESS;SOC];
  
  % Compute delta_M
  delta_M = M_est-M_exp;
  
  % Compute M_line
  M_line = M - delta_M;
  
 
    % Automatic Delta_P_Req for discharge and charge sequence based on SOC  
  if auto_delta_P_Req_flag==1
      %SOC(1)=0;
      % Charge
      if charge_flag==1
          delta_P_Req(t+1)=13800-P_ESS_Request_W_subset(t+1);
          if SOC(t)>0.90
              charge_flag=0;
              discharge_flag=1;
          end
      end
      % Discharge
      if discharge_flag==1
          delta_P_Req(t+1)=-13800-P_ESS_Request_W_subset(t+1);
          if SOC(t)<0.30
              charge_flag=1;
              discharge_flag=0;
          end
      end

  end
  
  
  
end     

% PESS_line=M_line(1,:);
% SOC_line=M_line(2,:);
% 
% SOC_est = round(SOC_est*100);
% SOC_exp = round(SOC_exp*100);
% SOC_line = round(SOC_line*100);
% SOC = round(SOC*100);



PESS_line=M_line(1,:);
SOC_line=M_line(2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Since the measurement resolution of both SOC and P_ESS signals is equal to 0.5 (half the increment of 1 unit, percent and kW, respectively), the systematic error found is 0.58 []. Then, this value 0.58 was added to the estimated signals PESS_est and SOC_est to compensate the systematic error.
%
% [ref] BIPM, IEC, IFCC, ILAC, ISO, IUPAC, IUPAP and OIML, Guide to the Expression of
% Uncertainty in Measurement, JCGM 100:2008 (GUM 1995 with minor
% corrections),  2008.  <http://www.bipm.org/utils/common/documents/jcgm/JCGM_100_2008_E.pdf>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compensation of the Systematic error (lines below)

SOC_est = round(SOC_est*100+0.58);
SOC_exp = round(SOC_exp*100+0.58);
SOC_line = round(SOC_line*100+0.58);
SOC = round(SOC*100+0.58);

% Compensation of the Systematic error (lines above)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
plot(SOC,'r');
hold on
plot(SOC_line,'b');
plot(SOC_subset(2:len),'k');
legend('SOC in the BESS','Fake SOC','SOC without attack');
hold off

figure(2)
plot(PESS,'r');
hold on
plot(PESS_line,'b');
plot(P_ESS_W_subset(2:len),'k');
legend('PESS in the BESS','Fake PESS','PESS without attack');
hold off

figure(3)
plot(delta_P_Req,'b');
legend('\Delta P_{Req}');
hold off

% % Plot the 5-minute moving avarage
% SOC_subset_=SOC_subset(2:len);
% P_ESS_W_subset_=P_ESS_W_subset(2:len);
% 
% for i=30:size(SOC,2)
%     
%     SOC_av(i)=mean(SOC(i-29:i));
%     SOC_line_av(i)=mean(SOC_line(i-29:i));
%     SOC_subset_av(i)=mean(SOC_subset_(i-29:i));
% 
%     PESS_av(i)=mean(PESS(i-29:i));
%     PESS_line_av(i)=mean(PESS_line(i-29:i));
%     P_ESS_W_subset_av(i)=mean(P_ESS_W_subset_(i-29:i));
% 
% end


% Plot the 5-minute avarage
SOC_subset_=SOC_subset(2:len);
P_ESS_W_subset_=P_ESS_W_subset(2:len);

for i=30:30:size(SOC,2)
    
    SOC_av(i/30)=mean(SOC(i-29:i));
    SOC_line_av(i/30)=mean(SOC_line(i-29:i));
    SOC_subset_av(i/30)=mean(SOC_subset_(i-29:i));

    PESS_av(i/30)=mean(PESS(i-29:i));
    PESS_line_av(i/30)=mean(PESS_line(i-29:i));
    P_ESS_W_subset_av(i/30)=mean(P_ESS_W_subset_(i-29:i));
    PESS_exp_av(i/30)=mean(PESS_exp(i-29:i));


end


figure(4)
plot(SOC_av,'r');
hold on
plot(SOC_line_av,'b');
plot(SOC_subset_av,'k');
legend('SOC in the BESS','Fake SOC','SOC without attack');
hold off

figure(5)
plot(PESS_av,'r');
hold on
plot(PESS_line_av,'b');
plot(P_ESS_W_subset_av,'k');
legend('PESS in the BESS','Fake PESS','PESS without attack');
hold off

% Compute P_U* (Fake PU)
load('P_U_dataset6.mat') %load measured P_U (without attack)

    % Compute the 5-minute avarage of PU (without attack)
    for i=60:60:size(P_U_W_subset,2)

        P_U_W_without_attack_av(i/60)=mean(P_U_W_subset(i-59:i));

    end

%P_U_W_without_attack_av=P_U_W_without_attack_av';

% Compute the estimated P_U when the attack is running
P_U_W_WITH_attack_av=P_U_W_without_attack_av-P_ESS_W_subset_av+PESS_av; % P_U(with_attack) = P_U(without_attack) - P_BESS(without_attack) + P*_BESS(with_attack)

% Compute the fake P_U when the attack is running
P_U_W_fake_av=P_U_W_WITH_attack_av-PESS_av+PESS_exp_av; % P_U(with_attack) = P_U(without_attack) - P_BESS(without_attack) + P*_BESS(with_attack)


figure(6)
plot(P_U_W_WITH_attack_av,'k');
hold on
plot(P_U_W_fake_av,'r');
plot(P_U_W_without_attack_av,'b');
legend('P_U with attack','P_U fake with attack','P_U without attack');
hold off

% Statistics

    % SOC Error
    SOC_error_av=abs(SOC_line_av-SOC_subset_av);
    SOC_error_av_RELATIVE=SOC_error_av/100;
    [SOC_muhat,SOC_sigmahat,SOC_muci,SOC_sigmaci] = normfit(SOC_error_av_RELATIVE);
        
    % PESS Error
    PESS_error_av=abs(PESS_line_av-P_ESS_W_subset_av);
    PESS_error_av_RELATIVE=PESS_error_av/13800;
    [PESS_muhat,PESS_sigmahat,PESS_muci,PESS_sigmaci] = normfit(PESS_error_av_RELATIVE);

    
    % PU Error
    P_U_error_av=abs(P_U_W_without_attack_av-P_U_W_fake_av); 
    P_U_error_av_RELATIVE=P_U_error_av/2.690200666666667e+04;
    [P_U_muhat,P_U_sigmahat,P_U_muci,P_U_sigmaci] = normfit(P_U_error_av_RELATIVE);
