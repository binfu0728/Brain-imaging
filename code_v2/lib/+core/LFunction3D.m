function L_r = LFunction3D(data,box,r)
    K_r = KFunction(data,box,r);
    L_r = nthroot(K_r/pi*(3/4),3) - r;
end