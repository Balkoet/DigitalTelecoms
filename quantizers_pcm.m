% Load the signal
[y, fs] = audioread('speech.wav'); 
signal = y / max(abs(y)); % normalisation
%Parameters
min_value = -1; 
max_value = 1; 
N_values = [2, 4, 8]; % N (bits)
K_max = 100; % max iters gia Lloyd-Max
epsilon = 1e-6; % threshold gia lloyd
% results kai plot counter gia ta plots
results = [];
results_mse = [];
plot_counter = 1;

for N = N_values
 L = 2^N; % Levels gia kvantisi
 delta = (max_value - min_value) / L; % vima kvantisis 
 % uniform quantizer
 xq_uni = round((signal - min_value) / delta); % antistoixisi levels
 xq_uni = max(min(xq_uni, L - 1), 0); %exasfalisi levels [0, L-1]
 s_quantized_uni = min_value + xq_uni * delta; % kvantismenes times
 SQNR_uni = calculate_sqnr(signal, s_quantized_uni); %sqnr
 MSE_uni = mean((signal - s_quantized_uni).^2); %mse

 % Lloyd-Max Quantizer (non-uniform)
 centers = linspace(min_value + delta/2, max_value - delta/2, L);
 for k = 1:K_max
 boundaries = [min_value, (centers(1:end-1) + centers(2:end))/2, max_value]; %ipologismos boundaries
 xq_L_M = zeros(size(signal)); %deigmata se zones
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
 SQNR_L_M = calculate_sqnr(signal, xq_L_M); 
 MSE_L_M = mean((signal - xq_L_M).^2);
 results = [results; N, SQNR_uni, SQNR_L_M];
 results_mse = [results_mse; N, MSE_uni, MSE_L_M];
   % Plot original and quantized signals
    subplot(length(N_values), 2, plot_counter);
    plot(signal, 'b-', 'DisplayName', 'Original Signal');
    hold on;
    plot(s_quantized_uni, 'r--', 'DisplayName', ['Uniform Quantized (N = ', num2str(N), ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend;
    title(['Uniform Quantization for N = ', num2str(N)]);
    grid on;
    plot_counter = plot_counter + 1;

    subplot(length(N_values), 2, plot_counter);
    plot(signal, 'b-', 'DisplayName', 'Original Signal');
    hold on;
    plot(xq_L_M, 'g--', 'DisplayName', ['Lloyd-Max Quantized (N = ', num2str(N), ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend;
    title(['Lloyd-Max Quantization for N = ', num2str(N)]);
    grid on;
    plot_counter = plot_counter + 1;
end

 uni_duration = length(s_quantized_uni) / fs; 
 L_M_duration = length(xq_L_M) / fs; 
 % Play sound
 fprintf('Now playing for N = %d using Uniform Quantizer...\n', N);
 sound(s_quantized_uni, fs);
 pause(uni_duration); 
 fprintf('Now playing for N = %d using Lloyd Max Quantizer...\n', N);
 sound(xq_L_M, fs);
 pause(L_M_duration); 

hold off;
%SQNR
figure;
plot(results(:, 1), results(:, 2), '-o', 'LineWidth', 2, 'DisplayName', 'Uniform Quantizer');
hold on;
plot(results(:, 1), results(:, 3), '-s', 'LineWidth', 2, 'DisplayName', 'Lloyd-Max Quantizer');
hold off;
set(gca, 'XTick', results(:, 1)); 
xticks(results(:, 1)); 
xticklabels({'N = 2', 'N = 4', 'N = 8'});
legend('Location', 'best');
xlabel('# Bits (N)');
ylabel('SQNR (dB)');
title('Comparison of SQNR between Uniform and  Lloyd-Max Quantizers');
grid on;

disp('Results of SQNR comparison:');
disp(table(results(:, 1), results(:, 2), results(:, 3), ...
 'VariableNames', {'N (Bits)', 'SQNR Uniform (dB)', 'SQNR LloydMax (dB)'}));

%MSE

figure;
plot(results_mse(:, 1), results_mse(:, 2), '-o', 'LineWidth', 2, 'DisplayName', 'Uniform Quantizer');
hold on;
plot(results_mse(:, 1), results_mse(:, 3), '-s', 'LineWidth', 2, 'DisplayName', 'Lloyd-Max Quantizer');
hold off;
set(gca, 'XTick', results_mse(:, 1)); 
xticks(results_mse(:, 1)); 
xticklabels({'N = 2', 'N = 4', 'N = 8'});
legend('Location', 'best');
xlabel('# Bits (N)');
ylabel('MSE');
title('Comparison of MSE between Uniform and Lloyd-Max Quantizers');
grid on;

disp('Results of MSE comparison:');
disp(table(results_mse(:, 1), results_mse(:, 2), results_mse(:, 3), ...
 'VariableNames', {'N (Bits)', 'MSE Uniform', 'MSE LloydMax'}));


function sqnr = calculate_sqnr(original_signal, quantized_signal)
 signal_power = mean(original_signal.^2);
 noise_power = mean((original_signal - quantized_signal).^2);
 sqnr = 10 * log10(signal_power / noise_power); %sqnr se db
end

