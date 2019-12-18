function matriz = matrizAcumulo(matriz)
% MATRIZACUMULO Sums all the values from previous columns.

    for k = 2:size(matriz,2)
        matriz(:, k) = matriz(:, k) + matriz(:, k-1);
    end
end

