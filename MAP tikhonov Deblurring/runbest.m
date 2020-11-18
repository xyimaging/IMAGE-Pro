function f_k = runbest(regulor,g,PSF,u_k,lambda,iter)

g = double(g);
% 
switch (regulor)
    case 'tikhonov'    
        % build tikhonov regularition term
        gamma = -1 * ones(3,3)/9;
        gamma(2,2) = gamma(2,2)+1;
        gamma_t = rot90(gamma,2);
    case 'TV'
        % build total variation
        gamma = [-1,0,1; ...
                 -2,0,2; ...
                 -1,0,1];
        gamma_t = rot90(gamma,2);
end

% build PSF
switch (PSF)
    case 'U_19'
        PSF = ones(19,19)./(19^2);
        
    case 'G_11'
        PSF = fspecial('gaussian',11,1.75);
        
    case 'G_5'
        PSF = fspecial('gaussian',5,1.5);     
end

% build PSF_t
PSF_t = rot90(PSF,2);

% fk, predicting value, initiated with g
f_k = g; 

% using iteration to reconstract
for j=1:iter
    % build H*fk, here we don't flat the image so...
    Hf = imfilter(f_k,PSF,'symmetric','same','conv');

    % the derivation of likelyhood term
    likelyhood = -2*(imfilter((g-Hf),PSF,'symmetric','same','conv'));

    % the derivation of tikhonov regularition term
    priori_r = imfilter(f_k,gamma,'symmetric','same','conv');
    priori_r = 2.*lambda.*imfilter(priori_r,gamma_t,'symmetric','same','conv');

    % define stepsize (step size is actually 2*u_k here)
    f_k = f_k - u_k.*(likelyhood + priori_r);

    % calculate the Lmap, use it as a judgement
    Lmap = norm(g - imfilter(f_k,PSF,'symmetric','same','conv')) +...
        lambda.*norm(imfilter(f_k,gamma,'symmetric','same','conv'));

end
    
end