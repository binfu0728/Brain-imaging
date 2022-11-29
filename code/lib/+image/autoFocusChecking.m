function zfocus = autoFocusChecking(zimg)
% input  : zimg, 3D image stack for focus images finding
% output : zfocus, a vector contains two values initial slice and final slice
% current version requires at least 20% images out of focus
    score = zeros(size(zimg,3),1);
    for j = 1:size(zimg,3)
        ydata    = frmethod(fft2(zimg(:,:,j)));
        score(j) = sum(ydata);
    end

    [idx,C]   = kmeans(score,4,'Start',[min(score);min(score)+1;max(score)-1;max(score)]);
    [~,order] = sort(C,'descend');
    in_idx    = find(idx==order(1) | idx==order(2)); %in-focus 
%     tr_idx    = find(idx==order(3)); %transition
%     out_idx   = find(idx==order(4)); %out-of-focus
    zfocus    = [in_idx(1),in_idx(end)];
end

function fr = frmethod(im1_fft)
    N = size(im1_fft);
    ndim = numel(N);
%     im1_fft = fft2(im1);
    
    xi = 0;
    for jj = 1:ndim
        xi = bsxfun( @plus, xi, reshape( ( -floor(0.5*N(jj)) : ceil(0.5*N(jj))-1 ).^2, [ones([1,jj-1]), N(jj), ones([1,2-jj])] ) );
    end
    xi = sqrt(ifftshift(xi));
    
    % Round values to integers for distribution to different Fourier shells
    shells = round(xi)+1; %
    
    % Number of Fourier frequencies in each cell
    n_xi = accumarray(shells(:), ones([numel(shells),1]));
    num_xi = numel(n_xi); 
    
    % Compute correlation on shells
    fr   =  accumarray(shells(:), log(abs(im1_fft(:))), [num_xi, 1])./n_xi;
    fr   = fr./fr(1);
    % 
    % % Restrict to values on shells that are fully contained within the image
    fr   = fr(1:ceil((min(N)+1)/4));
    n_xi = n_xi(1:ceil((min(N)+1)/4));
end