function [fit_spot,image_Region,sigmaY,sigmaX,bgEstimation,fit_spot_noBg] = gaussianFit(position,original_img) 
% Gaussian fitting function by using non-linear equation solver, derived from Lucien E. Weiss 
% INPUT
% position       : The position for a fitted point in [x,y] (centroid position)
% original_img   : The original image
% fitting_radius : The radius of fitting_region
% 
% OUTPUT
% fit_spot       : The fit spot based on the 2D gaussian fitting
% image_Region   : The original spot in the image
% sigmaY         : the sigma in y (row) for a fitted spot
% sigmaX         : the sigma in x (column) for a fitted spot
% bgEstimation   : Estimated background value for a given spot
% fit_spot_noBg  : The fit spot without background value

    fitting_radius                 = 5;
    amplitude_limits               = [0 2^16];
    amplitude_range                = diff(amplitude_limits);
    background_limits              = [0 2^16];
    background_range               = diff(background_limits);
    sigma_limits                   = [.1 fitting_radius];
    sigma_range                    = diff(sigma_limits);
    image_Region                   = original_img(position(2)-fitting_radius:position(2)+fitting_radius,position(1)-fitting_radius:position(1)+fitting_radius);
    theta_limits                   = [-pi/4 pi/4];
    theta_range                    =  diff(theta_limits);
    
    % Placeholder
    border_region                  = ones(fitting_radius*2+1); 
    border_region(2:end-1,2:end-1) = nan;
    fitting_options                = optimset('FunValCheck','on', 'MaxIter',1000, 'Display','off', 'TolFun',1e-4, 'TolX',1e-4);

    % Setup for localization
    [regional_indices_row,regional_indices_col] = ndgrid(-fitting_radius:fitting_radius,-fitting_radius:fitting_radius);
    
    % Intial guess
    BG_guess                       = (nanmean(border_region(:).*image_Region(:))-background_limits(1))/background_range;
    AMP_guess                      = (max(image_Region(:))-nanmean(border_region(:).*image_Region(:))-amplitude_limits(1))/amplitude_range;
    
    % non-linear fitting
    fitted_param                   = lsqnonlin(@ASYMMETRIC_GAUSSIAN_FIT, [.5, .5, AMP_guess, .5, .5, .5, BG_guess], [0 0 0 0 0 0 0], [1, 1, 1, 1, 1, 1, 1], fitting_options);
    [~,Guess_Image]                = ASYMMETRIC_GAUSSIAN_FIT(fitted_param);
    fit_spot                       = reshape(Guess_Image,fitting_radius*2+1,fitting_radius*2+1);
    sigmaY                         = fitted_param(4)*sigma_range+sigma_limits(1);
    sigmaX                         = fitted_param(5)*sigma_range+sigma_limits(1);
    bgEstimation                   = fitted_param(7)*background_range+background_limits(1);
    fit_spot_noBg                  = fit_spot - bgEstimation;
    
    function [Delta,Guess_Image] = ASYMMETRIC_GAUSSIAN_FIT(guess)
        Row         = (guess(1)-.5)*fitting_radius;
        Col         = (guess(2)-.5)*fitting_radius;
        Amplitude   = guess(3)*amplitude_range+amplitude_limits(1);
        Sigma_row   = guess(4)*sigma_range+sigma_limits(1);
        Sigma_col   = guess(5)*sigma_range+sigma_limits(1);
        Theta       = guess(6)*theta_range+theta_limits(1);
        Background  = guess(7)*background_range+background_limits(1);
        
        a           = ( cos(Theta)^2 / (2*Sigma_row^2)) + (sin(Theta)^2 / (2*Sigma_col^2));
        b           = (-sin(2*Theta) / (4*Sigma_row^2)) + (sin(2*Theta) / (4*Sigma_col^2));
        c           = ( sin(Theta)^2 / (2*Sigma_row^2)) + (cos(Theta)^2 / (2*Sigma_col^2));
    
        Guess_Image = Background + Amplitude*exp(-(a*(regional_indices_row-Row).^2 + 2*b*(regional_indices_row-Row).*(regional_indices_col-Col)+c*(regional_indices_col-Col).^2));
        Delta       = - image_Region(:) + Guess_Image(:);
    end
end
