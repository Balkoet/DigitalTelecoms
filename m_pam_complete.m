% Parametroi
ari8mos_bits = 50000;          % ari8mos bit gia transmit
M2 = 2;                    % M-PAM me M=2
M8 = 8;                    % M-PAM me M=8
SNR_dB = 0:2:20;           % times SNR se dB
Ts = 4e-6;                 % diarkeia symbolou 
Tc = 1/2.5e6;              % Periodos metaforas 
Tsamp = 0.1e-6;            % Periodos digmatolipseias 

% paragoume tixaia bits
bits = randi([0 1], 1, ari8mos_bits);

%Kuria loopa prosomiwsis
ber_gia_2_pam = zeros(1, length(SNR_dB));
ber_gia_8_pam = zeros(1, length(SNR_dB));
ser_gia_2_pam = zeros(1, length(SNR_dB));
ser_gia_8_pam = zeros(1, length(SNR_dB));

for snr_idx = 1:length(SNR_dB)
    % 2-PAM
    symbols_2pam = map_gia_2_pam(bits);
    received_2pam = kanali_awgn(symbols_2pam, SNR_dB(snr_idx));
    detected_2pam = sign(received_2pam);
    received_bits_2pam = (detected_2pam + 1)/2;
    [ber_gia_2_pam(snr_idx), ser_gia_2_pam(snr_idx)] = calculate_error_rates(bits, received_bits_2pam, symbols_2pam, detected_2pam);

    % 8-PAM
    symbols_8pam = map_gia_8_pam(bits(1:floor(length(bits)/3)*3));
    received_8pam = kanali_awgn(symbols_8pam, SNR_dB(snr_idx));
    % Apli anixnefsi threshold gia  8-PAM
    detected_8pam = round(received_8pam*2)/2;
    % Metatropi se bits
    received_bits_8pam = [];
    for i = 1:length(detected_8pam)
        decimal_value = round((detected_8pam(i) + 7)/2);
        binary = decimal2binary(decimal_value, 3);
        received_bits_8pam = [received_bits_8pam binary];
    end
    [ber_gia_8_pam(snr_idx), ser_gia_8_pam(snr_idx)] = calculate_error_rates(bits(1:length(received_bits_8pam)), received_bits_8pam, symbols_8pam, detected_8pam);

    % 8-PAM Kwdikopoiisi kata Gray (for BER only)
    symbols_8pam_gray = map_gia_8_pam_gray(bits(1:floor(length(bits)/3)*3));
    received_8pam_gray = kanali_awgn(symbols_8pam_gray, SNR_dB(snr_idx));
    detected_8pam_gray = round(received_8pam_gray * 2) / 2;
    received_bits_8pam_gray = apokwdikopoiisi_gray_gia_8_pam(detected_8pam_gray);
    [ber_gia_8_pam_gray(snr_idx), ~] = calculate_error_rates(bits(1:length(received_bits_8pam_gray)), received_bits_8pam_gray, symbols_8pam_gray, detected_8pam_gray);
end

% Apotelesmata se grafimata
figure;
semilogy(SNR_dB, ber_gia_2_pam, 'b-o', 'DisplayName', '2-PAM BER');
hold on;
semilogy(SNR_dB, ber_gia_8_pam, 'r-s', 'DisplayName', '8-PAM BER');
semilogy(SNR_dB, ber_gia_8_pam_gray, 'g-^', 'DisplayName', '8-PAM BER (Gray)');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
title('BER vs SNR for M-PAM');
legend('show');

figure;
semilogy(SNR_dB, ser_gia_2_pam, 'b-o', 'DisplayName', '2-PAM SER');
hold on;
semilogy(SNR_dB, ser_gia_8_pam, 'r-s', 'DisplayName', '8-PAM SER');
grid on;
xlabel('SNR (dB)');
ylabel('Symbol Error Rate');
title('SER vs SNR for M-PAM');
legend('show');

% Sinartisi gia na kanoume map ta bits se simvola 
function symbols = map_gia_2_pam(bits)
    symbols = 2*bits - 1;  % Map 0 to -1, 1 to +1
end

% Sinartisi gia na kanoume map ta bits se simvola 
function symbols = map_gia_8_pam(bits)
    % Metasximatismos bits se groups twn 3
    bits_reshaped = reshape(bits, 3, [])';
    symbols = zeros(1, size(bits_reshaped, 1));

    % Xeirokiniti metatropi binary se decimal
    for i = 1:size(bits_reshaped, 1)
        decimal = bits_reshaped(i,1)*4 + bits_reshaped(i,2)*2 + bits_reshaped(i,3);
        % simvola se 8-PAM epipeda (-7, -5, -3, -1, 1, 3, 5, 7)
        symbols(i) = 2*decimal - 7;
    end
    % Kanonikopoiisi energeias simvolou
    symbols = symbols/sqrt(mean(symbols.^2));
end

% Sinartisi metatropi decimal se binary
function binary = decimal2binary(decimal, ari8mos_bits)
    binary = zeros(1, ari8mos_bits);
    for i = ari8mos_bits:-1:1
        binary(i) = mod(decimal, 2);
        decimal = floor(decimal/2);
    end
end

% Sinartisi gia AWGN kanali
function received = kanali_awgn(transmitted, snr_db)
    snr = 10^(snr_db/10);
    noise_var = 1/(2*snr);
    noise = sqrt(noise_var)*randn(size(transmitted));
    received = transmitted + noise;
end

% ipologismos BER
function [ber, ser] = calculate_error_rates(transmitted_bits, received_bits, transmitted_symbols, received_symbols)
    ber = sum(transmitted_bits ~= received_bits)/length(transmitted_bits);
    ser = sum(transmitted_symbols ~= received_symbols)/length(transmitted_symbols);
end

% Sinartisi  gia na kanoume ta bits se simvola(M=8) me kwdikopoiisi kata Gray 
function symbols = map_gia_8_pam_gray(bits)
    %Metasximatismos twn bits se group twn 3
    bits_reshaped = reshape(bits, 3, [])';
    symbols = zeros(1, size(bits_reshaped, 1));
    
    % Gray mapping: Metatropi dekadikwn se binary
    gray_map = [-7, -5, -3, -1, 1, 3, 5, 7];  % Kata Gray kwdikopoiisi 8-PAM epipedwn
    for i = 1:size(bits_reshaped, 1)
        decimal = bits_reshaped(i, 1)*4 + bits_reshaped(i, 2)*2 + bits_reshaped(i, 3);
        symbols(i) = gray_map(decimal + 1);
    end   
    % Kanonikopoiisi energeias simvolou
    symbols = symbols / sqrt(mean(symbols.^2));
end

% Sinartisi apokwdikopoiisis twn kata Gray kwdikopoiimenwn simbolwn se bits
function binary = apokwdikopoiisi_gray_gia_8_pam(detected_symbols)
    gray_map = [-7, -5, -3, -1, 1, 3, 5, 7];  % Kata Gray kwdikopoiisi 8-PAM epipedwn
    binary_map = [0 0 0; 0 0 1; 0 1 1; 0 1 0; 1 1 0; 1 1 1; 1 0 1; 1 0 0];  % Ta bits tou kwdika Gray

    binary = [];
    for symbol = detected_symbols
        % Evresi kontinotero Gray bit sto simvolo
        [~, idx] = min(abs(symbol - gray_map));
        binary = [binary, binary_map(idx, :)];  % ta vazoume sta katalila bits
    end
end


