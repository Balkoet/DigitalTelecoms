function [kvantismena, centers] = kvantistis(x, N, min_value, max_value)

min_value = -3.5;
max_value = 3.5;

size_vima = (max_value - min_value) / 2^N; % Vriskw mege8os vimatos kvantisis
kvantismena = ones(size(x))*2^N; %Ftiaxnw tin mikroteri timi

%Evresi swstis perioxis
for i =1:size(x,1)
    for j = 1:2^N
        if x(i) >= max_value - size_vima*j
            kvantismena(i) = j;
            break;
        end
    end
end
centers = max_value - size_vima/2 - size_vima * (0:2^N-1)'; % Ypologismos centers 
end