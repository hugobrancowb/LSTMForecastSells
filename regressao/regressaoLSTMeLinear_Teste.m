clear;clc;
addpath('..\functions');
%load('C:\Users\Hugo\Documents\MATLAB\vendas1c\regressao\data\dadosDoTeste.mat')
load('C:\Users\Hugo\Documents\MATLAB\vendas1c\data\input2kk.mat')
load('C:\Users\Hugo\Documents\MATLAB\vendas1c\data\contarLucroPorCategoria_naoAcumulativo.mat')
vendas = soma;
load('C:\Users\Hugo\Documents\MATLAB\vendas1c\data\contarLucroPorCategoria.mat')
vendassoma = soma;

clear soma;
amostras = 84;
realdays = size(vendas,2);
prevdays = 31;
% dias "reais" : 638
% dias a prever: 31

for n=1:amostras
    % LINEAR
    y = vendassoma(n,1:end-prevdays);
    mu = mean(y);
    sig = std(y);
    y = (y - mu) ./ sig;
    
    yrealsoma = vendassoma(n,end-prevdays+1:end);
    Y = [(1:size(y,2))' y'];
    [trainedModel, ~] = regressaoLinear(Y);
    YPred = trainedModel.predictFcn((638-prevdays+1:638)');
    
    YPred = sig.*YPred + mu;
    y = sig.*y + mu;
    
    plotLinear = figure('visible','off');
    plot([y yrealsoma])
    hold on
    idx = size(y,2)+1:(size(y,2)+size(YPred,1));
    plot([638-30:638],[YPred'],'r')
    
    xlabel("Dias")
    ylabel("Vendas")
    title("Previsão de vendas: Linear")
    legend(["Real" "Previsão"],'Location','northwest')
    hold off    
    
    RMSE = sqrt((YPred' - yrealsoma).^2);
    errolinear(n) = mean(RMSE);
    
%     MLinear(n) = trainedModel;
    
    nome = "linear_";
    FILENAMELINEAR = strcat("plotsteste/",nome,num2str(n),".fig");
    saveas(plotLinear,FILENAMELINEAR);
    FILENAMELINEAR = strcat("plotsteste/",nome,num2str(n),".jpg");
    saveas(plotLinear,FILENAMELINEAR);
    
    % LSTM 
    y = vendas(n,1:end-prevdays);    
    yreal = vendas(n,end-prevdays+1:end);
    mu = mean(y);
    sig = std(y);
    
    if(sig ~= 0)
        dataTrainStandardized = (y - mu) ./ sig;
    else
        dataTrainStandardized = y;
    end

    XTrain = dataTrainStandardized(1:end-1);
    YTrain = dataTrainStandardized(2:end);
    
    XTrain2 = buffer(XTrain,5,4);
    YTrain2 = num2cell(YTrain);

    numFeatures = 5;
    numResponses = 1;
    numHiddenUnits = 300;

    layers = [ ...
     sequenceInputLayer(numFeatures)
     lstmLayer(numHiddenUnits)
     fullyConnectedLayer(numResponses)
     regressionLayer];

    options = trainingOptions('adam', ...
     'MaxEpochs',150, ...
     'GradientThreshold',1,...
     'InitialLearnRate',0.01, ...
     'LearnRateSchedule','piecewise', ...
     'LearnRateDropPeriod',30, ...
     'LearnRateDropFactor',0.7, ...
     'Verbose',0, ...
     'MiniBatchSize',1,...
     'Plots','none');

    net = trainNetwork(XTrain2,YTrain,layers,options);

    net = predictAndUpdateState(net,XTrain2);
    yend=YTrain(:,end-(numFeatures-1):end)';
    [net,YPred] = predictAndUpdateState(net,yend);
    YPred = [yend; YPred];

    numTimeStepsTest = prevdays;
    for i = 2:numTimeStepsTest+1
     [net,YPred(i)] = predictAndUpdateState(net,YPred(end-(numFeatures-1):end,1));
    end
    
%     MLSTM(n) = net;
    
    if(sig ~= 0)
        YPred = sig.*YPred + mu;
    end
    
    plotLSTM = figure('visible','off');
    plot([y yreal])
    hold on
    idx = size(YTrain,2)+1:(size(YTrain,2)+size(YPred,1));
    plot([idx(1)-1 idx],[y(end-1) YPred(1:end)'],'r')
    
    xlabel("Dias")
    ylabel("Vendas")
    title("Previsão de vendas: LSTM")
    legend(["Real" "Previsão"],'Location','northwest')
    hold off
    
    YPred = matrizAcumulo(YPred(2:end)) + vendassoma(n,end-31);
    
    RMSE = sqrt((YPred' - yrealsoma).^2);
    errolstm(n) = mean(RMSE);
    
    nome = "lstm_";
    FILENAMELSTM = strcat("plotsteste/",nome,num2str(n),".fig");
    saveas(plotLSTM,FILENAMELSTM);
    FILENAMELSTM = strcat("plotsteste/",nome,num2str(n),".jpg");
    saveas(plotLSTM,FILENAMELSTM);
end

MSRE = table(errolstm,errolinear,'VariableNames',["lstm" "linear"]);
save data/dadosDoTeste.mat MSRE
% system('shutdown -s');