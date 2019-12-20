clear;clc;
addpath('..\functions');
load('data\input2kk.mat')
load('data\contarLucroPorCategoria_naoAcumulativo.mat')
vendas = soma;
clear soma;

inicio = 1;
fim    = 84;

amostras = 84;
realdays = size(vendas,2);  % dias conhecidos
prevdays = 31;              % dias a prever

sellsPerDay = zeros(amostras,prevdays);
sellsCumulative = sellsPerDay;

parfor n=inicio:fim
    %% Standardize data
    y = vendas(n,:);
    
    mu = mean(y);
    sig = std(y);
    
    if(sig ~= 0)
        dataTrainStandardized = (y - mu) ./ sig;
    else
        dataTrainStandardized = y;
    end

    XTrain = buffer(dataTrainStandardized(1:end-1),5,4);
    YTrain = dataTrainStandardized(2:end);
    
    %% LSTM Configuration
    numFeatures = 5;
    numResponses = 1;
    numHiddenUnits = 300;

    layers = [ ...
     sequenceInputLayer(numFeatures)
     lstmLayer(numHiddenUnits)
     fullyConnectedLayer(numResponses)
     regressionLayer];

    options = trainingOptions('adam', ...
     'MaxEpochs',180, ...
     'GradientThreshold',1,...
     'InitialLearnRate',0.01, ...
     'LearnRateSchedule','piecewise', ...
     'LearnRateDropPeriod',30, ...
     'LearnRateDropFactor',0.7, ...
     'Verbose',0, ...
     'MiniBatchSize',1,...
     'Plots','none');

    %% Training the network
    % Initial train with the known values
    net = trainNetwork(XTrain,YTrain,layers,options);
    
    net = predictAndUpdateState(net,XTrain);
    
    yend=YTrain(1,end-(numFeatures-1):end)';
    [net,YPred] = predictAndUpdateState(net,yend); % "prevê" o ponto 638 (o ultimo conhecido)
    YPred = [yend(2:end); YPred]; % adiciona yend (size=4) porque preciso de 5 valores para a proxima previsao e o YPred só ganha um número de cada vez
    
    %% LSTM Prediction
    for i = 5:prevdays+4
     % selecionar apenas os últimos 5 numeros de YPred
     [net,YPred(i)] = predictAndUpdateState(net,YPred(end-(numFeatures-1):end,1));
    end
    
    % Descarta os 4 primeiros numeros
    YPred = YPred(5:end);
    YPred = YPred';
    %% De-standardize data
    if(sig ~= 0)
        YPred = sig.*YPred + mu;
    end
    
    %% Plot results
    plotPerDay = figure('visible','off');
    plot(y) % 638 points
    hold on
    plot(realdays:realdays+prevdays,[y(end) YPred],'r')
    
    xlabel("Dias")
    ylabel("Vendas")
    title("Previsão de vendas: LSTM")
    legend(["Real" "Previsão"],'Location','northwest')
    hold off
    
    FILENAME = strcat("plots/","perday_",num2str(n),".fig");
    saveas(plotPerDay,FILENAME);
    FILENAME = strcat("plots/","perday_",num2str(n),".jpg");
    saveas(plotPerDay,FILENAME);
    
    %% Cumulative profits over time
    SomaVendas = matrizAcumulo(vendas(n,:))'; % talvez mudar aqui pra economizar memoria
    YPred2 = [(YPred(1,1)+SomaVendas(end,1)) YPred(1,2:end)]; % mudar aqui pra economizar memória
    SomaPred = matrizAcumulo(YPred2);
    
    plotSoma = figure('visible','off');
    plot(SomaVendas)
    hold on
    plot(638:669,[SomaVendas(end) SomaPred],'r')
    hold off
    
    FILENAME = strcat("plots/","soma_",num2str(n),".fig");
    saveas(plotSoma,FILENAME);
    FILENAME = strcat("plots/","soma_",num2str(n),".jpg");
    saveas(plotSoma,FILENAME);
    
    %% Save Variables into matrix
    sellsPerDay(n,:)     = YPred;
    sellsCumulative(n,:) = SomaPred;
end

save data/Regressao.mat sellsPerDay sellsCumulative
clear;
% system('shutdown -s');