

classdef IPEdgeDetector < SYObject
properties(Constant)

end

methods(Static)

function result = edgeByKernel(image,connect)
    if connect == 4
        kernel = [0,-1,0; -1,4,-1; 0,-1,0];
    else
        kernel = [-1,-1,-1; -1,8,-1; -1,-1,-1];
    end
    
    jmage = IPKernelFilter.filteringWithKernel(image,kernel);
    
    result = jmage;
end

end
end
