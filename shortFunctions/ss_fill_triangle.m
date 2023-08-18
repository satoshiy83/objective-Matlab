

function ss_fill_triangle(bitmap,p,q,r,color)

siz = size(bitmap.var);

mask = SYData(zeros(siz(1),siz(2)));

r_min = round(min([p(1),q(1),r(1)]));
r_max = round(max([p(1),q(1),r(1)]));
c_min = round(min([p(2),q(2),r(2)]));
c_max = round(max([p(2),q(2),r(2)]));

ss_draw_line(mask,p,q,1);
ss_draw_line(mask,q,r,1);
ss_draw_line(mask,r,p,1);


for c = c_min:c_max
    v = mask.var(r_min:r_max,c);

    w = v(2:end) == 0 & v(1:end - 1) == 1;
    i = find(w);
    if isempty(i)
        continue
    end
    i = i + 1;

    w = v(1:end - 1) == 0 & v(2:end) == 1;
    t = find(w,1,"last");
    if isempty(t) || t < i
        continue
    end

    indices = (i:t) + r_min - 1;

    for i = 1:length(color)
        bitmap.var(indices,c,i) = color(i);
    end
end

end
