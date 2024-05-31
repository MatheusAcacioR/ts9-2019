% ANN para estimar SOC 
% Usamos Power_Request(t-1) e SOC(t-1) para estimar SOC(t) 
% ANN - 2-10-1, tansig

close all
clear all

name1 = 'Training_dataset6(24_days_subset).mat'; 
name2 = 'Testing_dataset6(24_days_subset).mat';
load(name1)

lenTr = size(P_ESS_W_subset,2);

startPos = 1;

P_ESS_W_subset = P_ESS_W_subset(1:2:lenTr);
SOC_subset = SOC_subset(1:2:lenTr);
lenTr = lenTr/2;

train_set = [P_ESS_W_subset(startPos:lenTr-1)/13800.0 ;SOC_subset(startPos:lenTr-1)/100.0];
output_set = [SOC_subset(startPos+1:lenTr)/100.0];

%[x,t] = house_dataset;
net = fitnet([20 5]);
net.trainParam.goal = .000001;
net.trainParam.epochs = 600;
net.layers{1}.transferFcn = 'purelin';
net.layers{2}.transferFcn = 'tansig';
%net.layers{3}.transferFcn = 'tansig';

net.performParam.regularization = 0;
net.divideParam.trainRatio = 90/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 5/100;
net.performFcn = 'mse';

net_SOC = train(net,train_set,output_set);
%view(net)


y = net_SOC(train_set);

y = round(y*100);
plot(y)

hold
plot(SOC_subset(startPos+1:lenTr),'r');

legend('SOC estimado','SOC original'); 
filename = strcat(name1,'SOC_Train.png'); 
saveas(gcf,filename);



load(name2);
lenTst = size(P_ESS_Request_W_subset,2);
P_ESS_W_subset = P_ESS_W_subset(1:2:lenTst); 
SOC_subset = SOC_subset(1:2:lenTst); 
lenTst = round(lenTst/2); 

y_ = ones(1,lenTst-1);
k=1;
for t = 1:lenTst-1
    
    if t == 1
        input_set = [ P_ESS_W_subset(t)/13800.0 ;SOC_subset(t)/100.0];
    else
        input_set = [ 0*P_ESS_W_subset(t)/13800.0; y_(t-1)];
        %input_set = [(Power_Request(t))/13800.0 SOC(t)/100.0 P_ESS(t)/13800.0]';
    end
    
    y_(t) = net_SOC(input_set); 
    k=k+1;
    
end

% = [(Power_Request(1:8639))/13800.0 SOC(1:8639)/100.0]';
%y = net(input_set);

y_ = round(y_*100);
figure
plot(y_)

hold
plot(SOC_subset(2:lenTst),'r');

legend('SOC estimado','SOC original'); 
filename = strcat(name2,'SOC_Test.png'); 
saveas(gcf,filename);

save('Neural_SOC.mat','net_SOC');