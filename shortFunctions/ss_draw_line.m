

function ss_draw_line(bitmap,p,q,color)

if length(p(:)) ~= length(q(:))
    return
elseif all(p(:) == q(:))
    return
elseif any([isnan(p(:)); isnan(q(:))])
    disp('Nan points cannot draw a line.')
    return
end
p = p(:);
q = q(:);

% Find the longest axis.
[L,I] = max(abs(p - q));
if p(I) > q(I)
    p_ = q;
    q = p;
    p = p_;
end

% Find origin and terminal point.
o = round(p);
t = round(q);

% Enumerate axes.
m = zeros(t(I) - o(I) + 1,length(p));
m(:,I) = o(I):t(I);

l = (o(I):t(I)) - p(I);

axes = 1:length(p);
axes(I) = [];
for i = axes
    d = t(i) - o(i);
    s = sign(d);
    if s == 0
        m(:,i) = round(p(i));
        continue
    end

    array = (o(i):s:t(i))';
    d = L * (array - p(i)) - (q(i) - p(i)) * l;
    [~,indices] = min(abs(d));
    m(:,i) = array(indices);
end
m = m - 1;

siz = size(bitmap.var);
A = cumprod(siz);
A = [1,A(1:end - 1)]';
indices = m * A + 1;

bitmap.var(indices) = color;
end
