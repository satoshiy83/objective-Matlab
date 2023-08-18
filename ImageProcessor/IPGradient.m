

classdef IPGradient < IPKernelFilter
properties(Constant)
    
end

methods(Static)

function result = Prewitt(image)
    kernel = [1; 1; 1] * [1,0,-1];
    jmage = IPGradient.filteringWithKernel(image,kernel);
    
    kernel = [1; 0; -1] * [1,1,1];
    kmage = IPGradient.filteringWithKernel(image,kernel);
    
    array = kmage.representations;
    jmage.addRepresentation(array.objectAtIndex(1));
    
    result = jmage;
end
function result = Sobel(image)
    kernel = [1; 2; 1] * [1,0,-1];
    jmage = IPGradient.filteringWithKernel(image,kernel);
    
    kernel = [1; 0; -1] * [1,2,1];
    kmage = IPGradient.filteringWithKernel(image,kernel);
    
    array = kmage.representations;
    jmage.addRepresentation(array.objectAtIndex(1));
    
    result = jmage;
end

end
end
