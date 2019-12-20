function importSells(total)
% salestrain(total) - import 'total' first sales from dataset. Use 0 to
% import all dataset.

opts = delimitedTextImportOptions("NumVariables", 6);

% Specify range and delimiter
if(total == 0)
    opts.DataLines = [2, Inf];
else
    opts.DataLines = [2, total+1];
end

opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["date", "date_block_num", "shop_id", "item_id",...
                      "item_price", "item_cnt_day"];
opts.VariableTypes = ["datetime", "double", "double", "double",...
                      "double", "double"];
opts = setvaropts(opts, 1, "InputFormat", "dd.MM.yyyy");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
soma = readtable("CVS\sales_train_v2.csv", opts);
soma = sortrows(soma,1);    % organiza por ordem de data.
save data/input.mat soma
end

