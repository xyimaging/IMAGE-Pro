function [img_recov, V] = pyramid_iter2(img, img_trans, p_n, o_n)
% if using pyramid&iteration
p_iter = p_n; % the iter number 
o_iter = o_n;

% Arch_img
r_img = double(img);
a_img = double(img_trans);

% build pyramid
orig_pyramid = cell(p_iter, 1);
trans_pyramid = cell(p_iter, 1);
blurred_orig = cell(p_iter,1);
blurred_trans = cell(p_iter,1);

% the largest level is the original image
orig_pyramid{p_iter} = r_img;
blurred_orig{p_iter} = r_img;
trans_pyramid{p_iter} = a_img;
blurred_trans{p_iter} = a_img;

% blurring kernal
PSF = fspecial('gaussian',5,1.5); 

for i = p_iter-1:-1:1
    orig_pyramid{i} = impyramid(double(orig_pyramid{i+1}),'reduce');
    trans_pyramid{i} = impyramid(double(trans_pyramid{i+1}),'reduce');
    
    blurred_orig{i} = impyramid(double(imfilter( ...
        blurred_orig{i+1},PSF,'symmetric','same','conv')),'reduce');
    blurred_trans{i} = impyramid(double(imfilter( ...
        blurred_trans{i+1},PSF,'symmetric','same','conv')),'reduce');
end

% Initialize parameters
V = [0;0];
V = double(V);
% Iterate through pyramids
for j = 1:p_iter
    V = V.*2;
    temp_img = imtranslate(blurred_trans{j},[-V(1),-V(2)]);
    [fx, fy] = imgradientxy(blurred_orig{j}); 
    fx2 = fx.^2;
    fxy = fx.*fy;
    fy2 = fy.^2;
    % Iterations of single level image
    for i = 1:o_iter
        ft = double(temp_img)-double(blurred_orig{j});
        fxt = fx.*ft;
        fyt = fy.*ft;
        V_hat = [sum(fx2(:)),  sum(fxy(:));  sum(fxy(:)), ...
            sum(fy2(:))]\[sum(fxt(:));sum(fyt(:))];
        V = V-V_hat;
        temp_img = imtranslate(blurred_trans{j},[-V(1),-V(2)]);
    end
end

img_recov = temp_img;

end
