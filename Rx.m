function [R, r]  = Rx(p, x)

R = zeros(p);
r = zeros(p,1);

N = size(x,1);

for i = 1:p
    sum = 0;
    for n = p+1 : N
       sum = sum + x(n) * x(n-i);
    end
    r(i) =  1/(N-p) *sum;    
end

for i = 1:p
    for j = 1:p
        sum = 0;
        for n = p+1 : N
           sum = sum + x(n-j) * x(n-i);
        end
        R(i,j) =  1/(N-p) *sum;    
    end
end


end