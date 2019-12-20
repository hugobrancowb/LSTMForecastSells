# LSTMForecastSells
## Introduction
It was provided by [1C Company](http://www.1c.com/) a time-series dataset consisting of daily sales data for a data science competition hold by [Kaggle](https://www.kaggle.com/).
You can download the dataset from [this link](https://www.kaggle.com/c/competitive-data-science-predict-future-sales/data).

All CVS files must be inside ```/CVS/``` folder.

## Functions / How to run it
### Import sales from dataset.
```Matlab
[vendas rangeDays ProductIDS] = importSells(total)

% vendas - table containing all data sales.
% rangeDays - array of days that can hold all sales dates, from beginning to end, leaving no "blank" days.
% ProductIDS - array of the products' ID the stores can sell.
```

### Reorganize the dataset and calculate: sales *or* profit *(SellOrProfit input)*;

The table is segmented by: Product *or* Category of Products *(ProdOrCat input)*; 

values are: each day *or* accumulative values *(Accu input)*;

```Matlab
[soma rangeDays ProductIDS] = contarVendasPorProduto(SellOrProfit,ProdOrCat,Accu)
% SellOrProfit - string - "sells" or "profit"
% ProdOrCat - string - "product" or "category"
% Accu - logic - 1 returns accumulative values

% save somas into 'data' folder
save data\input2kk.mat soma
```

### (Optional) Compare Linear and LSTM Regression Models
```Matlab
regressaoLSTMeLinear
```
Must have 2 segmented datasets saved: ```data\contarLucroPorCategoria_naoAcumulativo.mat``` and ```data\contarLucroPorCategoria.mat```, as well as ```data\input2kk.mat```.
The first data is the output of ```contarVendasPorProduto("profit","category",0)``` while the second one is ```contarVendasPorProduto(profit,category,1)```, both having the ```soma``` variable.

This function will save the comparative MSRE as a table into ```data/dadosDoTeste.mat```

### Run LSTM Regression
This script will take a while. It will save all output inside ```regressao/data/``` folder including regression plots.

```Matlab
regressaoLSTM
```