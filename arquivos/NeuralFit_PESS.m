% ANN para estimar SOC 
% Usamos Power_Request(t-1) e SOC(t-1) para estimar SOC(t) 
% ANN - 2-10-1, tansig

close all
clear all
name1 = 'Training_dataset6(24_days_subset).mat'; 
name2 = 'Testing_dataset6(24_days_subset).mat';
load(name1)

lenTr = size(P_ESS_Request_W_subset,2);

P_ESS_Request_W_subset = P_ESS_Request_W_subset(1:2:lenTr);
SOC_subset = SOC_subset(1:2:lenTr);
P_ESS_W_subset = P_ESS_W_subset(1:2:lenTr);
lenTr = lenTr/2;

startPos = 1;


% train_set = [(Power_Request_W(1:34559))/13800.0 SOC_(1:34559)/100.0 P_BESS_W(1:34559)/13800.0]';

train_set = [(P_ESS_Request_W_subset(startPos:lenTr-1))/13800.0; SOC_subset(startPos:lenTr-1)/100.0; P_ESS_W_subset(1:lenTr-1)/13800.0];
output_set = [P_ESS_W_subset(startPos+1:lenTr)/13800.0];

%[x,t] = house_dataset;
net = fitnet([15 10 5]);
net.trainParam.goal = .000001;
net.trainParam.epochs = 600;
net.layers{1}.transferFcn = 'purelin';
net.layers{2}.transferFcn = 'tansig';
net.layers{3}.transferFcn = 'tansig';

net.performParam.regularization = 0;
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 10/100;

net_PESS = train(net,train_set,output_set);
%view(net)


y = net_PESS(train_set);

y = round(y*13800.0);
plot(y)

hold
plot(P_ESS_W_subset(startPos+1:lenTr),'r');

legend('PESS estimado','PESS original'); 
filename = strcat(name1,'PESS_Train.png'); 
saveas(gcf,filename);




load(name2);

lenTst = size(P_ESS_Request_W_subset,2);
P_ESS_Request_W_subset = P_ESS_Request_W_subset(1:2:lenTst);
SOC_subset = SOC_subset(1:2:lenTst);
P_ESS_W_subset = P_ESS_W_subset(1:2:lenTst);
lenTst = round(lenTst/2);


y_ = ones(1,lenTst);

for t = 1:lenTst
    
    if t == 1
        input_set = [(P_ESS_Request_W_subset(t))/13800.0 ; SOC_subset(t)/100.0; P_ESS_W_subset(t)/13800.0];
        %input_set = [(Power_Request(t))/13800.0 SOC(t)/100.0 P_ESS(t)/13800.0]';
    else
        %input_set = [(P_ESS_Request_W_subset(t))/13800.0 ; SOC_subset(t)/100.0];
        input_set = [(P_ESS_Request_W_subset(t))/13800.0 ; SOC_subset(t)/100.0 ; y_(t-1)];
        %input_set = [(Power_Request(t))/13800.0 SOC(t)/100.0 P_ESS(t)/13800.0]';
    end
    
    y_(t) = net_PESS(input_set);
end


figure
y_ = round(y_*13800.0);
plot(y_)

hold
plot(P_ESS_W_subset(2:lenTst),'r');

legend('PESS estimado','PESS original'); 
filename = strcat(name2,'PESS_Test.png'); 
saveas(gcf,filename);

save('Neural_PESS.mat','net_PESS');