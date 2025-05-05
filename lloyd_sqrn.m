[y, fs] = audioread('speech.wav'); 
signal = y / max(abs(y)); %normalisation
% Parameters
min_value = -1; 
max_value = 1; 
N_values = [2, 4, 8]; %  N (bits)
K_max_values = [10, 50, 100, 200, 500]; % K_max
epsilon = 1e-6; % threshold
SQNR_results = zeros(length(N_values), length(K_max_values));

for n_idx = 1:length(N_values)
 N = N_values(n_idx);  
 L = 2^N; % #levels kvantisis
 delta = (max_value - min_value) / L; %vima kvantisis
 for k_idx = 1:length(K_max_values)
 K_max = K_max_values(k_idx);
 % Lloyd-Max
 centers = linspace(min_value + delta/2, max_value - delta/2, L); 
 for k = 1:K_max
 boundaries = [min_value, (centers(1:end-1) + centers(2:end))/2, max_value]; %ipologismos boundaries
 xq_L_M = zeros(size(signal)); % kvantisi, samples se levels
 for i = 1:length(signal)
 for j = 1:L
 if signal(i) >= boundaries(j) && signal(i) < boundaries(j+1)
 xq_L_M(i) = centers(j);
 break;
 end
 end
 end
 new_centers = zeros(1, L);
 for j = 1:L
 indices = signal >= boundaries(j) & signal < boundaries(j+1);
 if sum(indices) > 0
 new_centers(j) = mean(signal(indices));
 else
 new_centers(j) = centers(j); % an den exoume nea deigmata kratame ta proigoumena
 end
 end
 if max(abs(new_centers - centers)) < epsilon %check to stop
 break;
 end
 centers = new_centers;
 end
 signal_power = mean(signal.^2);
 noise_power = mean((signal - xq_L_M).^2);
 SQNR_results(n_idx, k_idx) = 10 * log10(signal_power / noise_power); %sqnr se db
 end
end
%SQNR
figure;
hold on;
colors = ['r', 'g', 'b']; 
for n_idx = 1:length(N_values)
 plot(K_max_values, SQNR_results(n_idx, :), '-o', 'Color', colors(n_idx), 'LineWidth', 1.5, ... 
    'DisplayName', ['N = ', num2str(N_values(n_idx))]);
end
hold off;
title('SQNR vs #iterations Lloyd-Max');
xlabel('K_{max} #iterations');
ylabel('SQNR (dB)');
grid on;
legend('show');


