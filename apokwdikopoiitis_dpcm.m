function anakataskevi = apokwdikopoiitis_dpcm(kwdikopoiimena, a, centers)
% kwdikopoiimena : sima pros kwdikopoiisi    a: sintelestes gia provepsi
% pros8etw stoixeia stin arxi tis mnimis gia na doulepsoun oi prwtes p
% provlepseis
p = size(a,1);
y_memory = zeros(size(kwdikopoiimena,1)+p,1);
anakataskevi = size(kwdikopoiimena);
kwdikopoiimena = [zeros(p,1); kwdikopoiimena];

%kwdikopoiisi
for i  =  p + 1 : size(kwdikopoiimena,1)
    provlepsi = provleptis(a,y_memory(i-p:i-1));
    anakataskevi(i-p) = centers(kwdikopoiimena(i)) + provlepsi;
    y_memory(i) = anakataskevi(i-p);
end
%anakataskevi : anakataskevasmeno sima
end