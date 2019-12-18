function [MSRE] = MSRE(A,B)
MSRE = mean(sqrt((A-B).^2));
end

