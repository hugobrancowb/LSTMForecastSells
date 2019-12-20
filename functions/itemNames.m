function names = itemNames(listaID)
% ITEMNAMES Gets a column of Product IDs and returns the names of those IDs.

% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 2);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["item_id", "item_name_translated"];
opts.VariableTypes = ["double", "string"];
opts = setvaropts(opts, 2, "WhitespaceRule", "preserve");
opts = setvaropts(opts, 2, "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
itemstranslated = readtable("CVS\items-translated.csv", opts);
clear opts

names = (itemstranslated.item_name_translated(listaID));

end

