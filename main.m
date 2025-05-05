load source.mat;
plot(t)
%sound(t); not clear
%% 
load source.mat;
p = 5;
[R, r] = Rx(p, t);
%%
a = R\r;
[a_kvantismenes_perioxes, a_centers] = kvantistis(a, 8, -2, 2);
a_kvantismena = a_centers(a_kvantismenes_perioxes);
%%
N = 4;
min_value = -3.5;
max_value = 3.5;
[kwdikopoiimena, centers, a, y] = kwdikopoiitis_dpcm(t, p, N, min_value, max_value);
anakataskevi = apokwdikopoiitis_dpcm(kwdikopoiimena, a, centers);
%%
t';
plot(anakataskevi);
%% 

%2
for p = [5, 10]
    for N = 1:3
        [encoded, centers, a, y] = kwdikopoiitis_dpcm(t, p, N, min_value, max_value);
        figure;
        plot(t);
        hold on
        plot(y);
        hold off
    end
end
%%
MSE = zeros(10, 3);
for p = 5:10
    for N = 1:3
        [kwdikopoiimena, centers, a, y] = kwdikopoiitis_dpcm(t, p, N, min_value, max_value);
        anakataskevi = apokwdikopoiitis_dpcm(kwdikopoiimena, a, centers);
        MSE(p, N) = 1/size(anakataskevi, 2) * sum((t - anakataskevi').^2);
    end
end

% Create heatmap for MSE
figure;
imagesc(MSE(5:10, 1:3)); 
colorbar;
xlabel('N');
ylabel('p');
title('MSE Heatmap');
set(gca, 'YTick', 1:6, 'YTickLabel', 5:10); 
set(gca, 'XTick', 1:3, 'XTickLabel', 1:3); 
%% 

%4
for p = [5, 10]
    for N = 1:3
        [kwdikopoiimena, centers, a, y] = kwdikopoiitis_dpcm(t, p, N, min_value, max_value);
        reconstructed = apokwdikopoiitis_dpcm(kwdikopoiimena, a, centers);

        figure;
        plot(anakataskevi);
    end
end
%%
%og print
figure;
plot(t);