function [vendas rangeDays ProductIDS] = contarVendasPorProduto(SellOrProfit,ProdOrCat,Accu)
% SellOrProfit - sells/profit - venda por dia ou vendas totais no intervalo?
% ProdOrCat - product/category - produto ou categoria?
% Accu - 1 é acumulo de valores; 0 nao soma o acumulo.

load('data/input.mat', 'input');
switch SellOrProfit
    case "sells"
        selection = 1;
    case "profit"
        selection = 0;
    otherwise
        error("Entrada 1 é inválida.");
end
switch ProdOrCat
    case "product"
        selection = selection+2;
    case "category"
    otherwise
        error("Entrada 2 é inválida.");
end

selection = sells + product;

ProductIDS = sort(unique(input.item_id));   % Array das ID de produto
minDay = input.date( 1 );
maxDay = input.date(end);
rangeDays = days(maxDay-minDay) + 1;

if(product == 0)
    load('data/input2kk.mat', cat2name,id2cat);
    vendas = zeros(size(cat2name,1),rangeDays);
else
    vendas = zeros(size(ProductIDS,1),rangeDays);
end

for k = 1:size(ProductIDS,1)
    
    ID = ProductIDS(k);
    
    index = (input.item_id == ID);
    thisProduct = input(index,:);     % Apenas o produto atual em table
    dia = days(thisProduct.date - minDay) + 1;
    
    switch selection
        case 0 % profit of each category
        case 1 % number of sells of each category
        case 2 % profit of each product
            for d = 1:size(thisProduct,1)       
            vendas(k, dia(d)) = vendas(k, dia(d)) + ...
                thisProduct.item_cnt_day(d)*thisProduct.item_price(d);
            end
        case 3 % number of sells of each product
            for d = 1:size(thisProduct,1)       
            vendas(k, dia(d)) = vendas(k, dia(d)) + ...
                thisProduct.item_cnt_day(d);
            end
    end
    
    
    if (SellOrProfit == "sells")
        for d = 1:size(thisProduct,1)       
            vendas(k, dia(d)) = vendas(k, dia(d)) + ...
                thisProduct.item_cnt_day(d);
        end
    else
        for d = 1:size(thisProduct,1)       
            vendas(k, dia(d)) = vendas(k, dia(d)) + ...
                thisProduct.item_cnt_day(d)*thisProduct.item_price(d);
        end
    end
    
end

% matriz se transforma em soma dos valores (acumulo de dados ao longo do tempo):
if(Accu == "acumulo")
    vendas = matrizAcumulo(vendas);
end

end