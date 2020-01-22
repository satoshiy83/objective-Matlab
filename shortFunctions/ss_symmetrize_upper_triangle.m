% Short script to symmetrize matrix.
% Written by Satoshi Yamashita.

function result = ss_symmetrize_upper_triangle(m)
% Function symmetrize given matrix.
% result = ss_symmetrize_upper_triangle(m)
% Argument m is a matrix.
% Return value is a symmetric matrix made from upper triangle of given
% matrix.
if length(size(m)) > 3
    disp('Dimension of m must be 2 or 3.');
    return;
end
if size(m,1) ~= size(m,2)
    disp('m must be square.');
    return;
end

for z = 1:size(m,3)
    m(:,:,z) = m(:,:,z) - tril(m(:,:,z),-1) + triu(m(:,:,z),1)';
end

result = m;
end
