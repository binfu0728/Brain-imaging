function img = normalize16(img)
    img = img - min(min(img)) + 1;
    img = uint16(img./max(max(img)) .* (2^16-1));
end