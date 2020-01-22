
function result = ss_draw_circle(cx,cy,r)

t = 0:0.01:2 * pi;
xp = r * cos(t);
yp = r * sin(t);

result = plot(cx + xp,cy + yp);
end
