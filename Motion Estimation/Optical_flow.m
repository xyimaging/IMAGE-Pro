function [img_recov, V] = Optical_flow(img, img_trans, pyramid, p_n, o_n)

switch (pyramid)
    case 'T'    
        % if using pyramid&iteration
        p_iter = p_n; % the iter number 
        o_iter = o_n;
    case 'F'
        p_iter = 0;
        o_iter = o_n;
end

% Arch_img
r_img = double(img);
a_img = double(img_trans);
% the recovered img
img_recov = zeros([size(r_img,1),size(r_img,2)]);
% the total motion
V = [0, 0];
V = double(V);

% calculate the gradiate in fx and fy
[fx, fy] = imgradientxy(r_img); 
fx2 = fx.^2;
fy2 = fy.^2;
fxy = fx.*fy;
fyx = fxy;

% for i = 1:o_iter
%     % calculate the ft = f2 - f1
%     ft = a_img - r_img;
%     % calculate [f1x*ft ; f1y*ft]
%     fxt = fx.*ft;
%     fyt = fy.*ft;
%     % calculate v_hat
%     V_hat = inv([sum(fx2(:)),sum(fxy(:));sum(fyx(:)),sum(fy2(:));]) ...
%         * [sum(fxt(:));sum(fyt(:))];
%     V_hat = V_hat';
%     % calculate the total shift
%     V = V+V_hat;
%     % shift the original image in the directin
%     r_img = imtranslate(r_img,V);
%  
% end
templet = a_img;
for i = 1:o_iter
    % calculate the ft = f2 - f1
    ft = templet - r_img;
    % calculate [f1x*ft ; f1y*ft]
    fxt = fx.*ft;
    fyt = fy.*ft;
    % calculate v_hat
    V_hat = ([sum(fx2(:)),sum(fxy(:));sum(fyx(:)),sum(fy2(:));]) ...
        \ [sum(fxt(:));sum(fyt(:))];
    V_hat = V_hat';
    % calculate the total shift
    V = V-V_hat;
    % shift the original image in the directin
    templet = imtranslate(a_img,-V);
end
% shift the arch_img back to recover the image
img_recov = imtranslate(a_img,-V);
end