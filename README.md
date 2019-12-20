# LSTMForecastSells
## Introduction
It was provided by [1C Company](http://www.1c.com/) a time-series dataset consisting of daily sales data for a data science competition hold by [Kaggle](https://www.kaggle.com/).
You can download the dataset from [this link](https://www.kaggle.com/c/competitive-data-science-predict-future-sales/data).

## Functions / How to run it
1. Import sales from dataset.
```Matlab
[vendas rangeDays ProductIDS] = importSells(total)

% vendas - table containing all data sales.
% rangeDays - array of days that can hold all sales dates, from beginning to end, leaving no "blank" days.
```
*vendas* - table containing all data sales.

*rangeDays* - array of days that can hold all sales dates, from beginning to end, leaving no "blank" days.

*ProductIDS* - array of the products' ID the stores can sell.

