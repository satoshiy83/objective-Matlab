

classdef IPBlurFilter < IPKernelFilter
properties(Constant)

end

methods(Static)

function result = gaussianBlur(image,sigma)
    r = round(sigma * 3);
    d = ones(r * 2 + 1,1) * [-r:r];
    d = d .^ 2 + (d .^  2)';
    kernel = zeros(r * 2 + 1);
    sig = 2 * sigma ^ 2;
    for i = 1:length(d(:))
        kernel(i) = exp(-d(i) / sig) / (pi() * sig);
    end
    
    jmage = IPBlurFilter.filteringWithKernel(image,kernel);
    
    result = jmage;
end

function result = diskBlur(image,r)
    d = ones(r * 2 + 1,1) * [-r:r];
    d = d .^ 2 + (d .^ 2)';
    kernel = double(d < r ^ 2);
    kernel = kernel / sum(kernel(:));
    
    jmage = IPBlurFilter.filteringWithKernel(image,kernel);
    
    result = jmage;
end

end
end
