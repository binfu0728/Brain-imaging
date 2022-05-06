function L_r = LFunction2D(data,box,r)
    K_r = KFunction(data,box,r);
    L_r = sqrt(K_r/pi)-r;
end