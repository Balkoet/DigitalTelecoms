function [y_sfalma_kvantismeno, centers, a_kvantismena, y_sfalma]  = kwdikopoiitis_dpcm(x, p, N, min_value, max_value)
%x: sima pros kwdikopoiisi p: parel8ontikes times deigmatos gia provlepsi
%y_sfalma_kvantismeno: to kvantismeno sfalma pou 8a stalei
%a_kvantismena: sintelestes Rx pou evgale o kwdikopoiitis 
min_value = -3.5;
max_value = 3.5;

%Ipologizw posotites gia provelsi
[R,r] = Rx(p,x);
a = R\r;
[a_kvantismena, a_centers] = kvantistis(a, 8, -2, 2);
a_kvantismena = a_centers(a_kvantismena);

% pros8etw stoixeia stin arxi tis mnimis gia na doulepsoun oi prwtes p
% provlepseis
y_memory = zeros(size(x,1)+p,1);
y_sfalma_kvantismeno = zeros(size(x));
y_sfalma = zeros(size(x));

x = [ zeros(p,1); x ];
%kwdikopoiisi
for i  =  p + 1 : size(x,1)
    provlepsi = provleptis(a_kvantismena,y_memory(i-p:i-1));
    y_sfalma(i-p) = x(i) - provlepsi;
    [y_sfalma_kvantismeno(i-p), centers] = kvantistis(y_sfalma(i-p), N, min_value, max_value);
    y_memory(i) = provlepsi + centers(y_sfalma_kvantismeno(i-p));
end
end