

function result = ss_project_z(image)

if image.countStack < 2
    result = image.copy;
    return
end

bitmapRep = image.representations.objectAtIndex(1);
bitmap = bitmapRep.bitmap.var;

for i = 2:image.representations.count
    bitmapRep = image.representations.objectAtIndex(i);
    if bitmapRep.repType == SYBitmapImageRep.RepTypeImage
        bitmap = cat(4,bitmap,bitmapRep.bitmap.var);
    end
end

bitmap = max(bitmap,[],4);
result = SYImage(SYData(bitmap));
end
