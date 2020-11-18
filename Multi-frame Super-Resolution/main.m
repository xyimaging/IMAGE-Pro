clc;
clear;
close all;

%% import images
g0 = imread('cameraman_Original.tif');
g0 = double(g0)/255;
% 
PSF = fspecial('gaussian',5,1.5);
g_blur = imfilter(g0,PSF,'symmetric','same','conv');
%
figure();subplot(1,2,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,2,2);imagesc(g_blur);title('Blurred Image');
axis image;colormap gray
%% Generating Frames
factor = 4;
m = 0;
var = 0.01;

image_frame = zeros([16,64,64]);
image_motion = zeros([16,2]);
% motion in 2 axises
x_ = [0,-1,-2,-3];
y_ = [0,-1,-2,-3];
n = 1;
phi = zeros(256,256);
for x_k = 1:4
    for  y_k = 1:4
        image_motion(n,:) = [x_(x_k),y_(y_k)];
        % shift
        image_Frame = zeros(256,256);
        %image_Frame(1+x_(x_k):end,1+y_(y_k):end) = g_blur(1:256-x_(x_k),1:256-y_(y_k));
        image_Frame(1:256+x_(x_k),1:256+y_(y_k)) = g_blur(1-x_(x_k):256,1-y_(y_k):256);
        % dawn-sampling and add noise
        image_frame(n,:,:) = image_Frame(1:factor:end, 1:factor:end);
        % before using this guassian noise, must transfer uint to [0,1]
        image_frame(n,:,:) = imnoise(image_frame(n,:,:),'gaussian',m,var);
        n = n+1;
        phi(1-x_(x_k):factor:256,1-y_(y_k):factor:256) =  ...
            phi(1-x_(x_k):factor:256,1-y_(y_k):factor:256)+1;
        
    end
end

figure()
for k =1:6
    subplot(2,3,k);
    imagesc(squeeze(image_frame(k,:,:)));title(['S & D Image ',num2str(k)]);
    axis image;colormap gray
end

%% frame number = 16
% solve the shift & add step
u_k = 0.01;
lambda = 0.4;
max_iter = 2000;
factor = 4;
norm_ = "norm2";
z_k = Multiframe_SR(image_frame,image_motion,factor,u_k,lambda,max_iter);

% deblurring
u_k = 0.005;
PSF = 'G_5';
regulor = 'tikhonov';
lambda = 1;
iter = 1500;
% MAP (here since the BSNR is low, means the obeservation is not reliable)
best_fk = hw6_runbest(regulor,z_k,PSF,u_k,lambda,iter,phi);% when using TV set lambda = 0.001

figure()
subplot(1,2,1);imagesc(z_k);title('shift&add');
axis image;colormap gray
subplot(1,2,2);imagesc(best_fk);title('deblurring');
axis image;colormap gray

err = immse(best_fk, g0);
fprintf('\n The MSE of 16 frame n2 reconstruction is %0.4f\n', err);
%% frame number = 12
% solve the shift & add step
u_k = 0.01;
lambda = 10;
max_iter = 2000;
factor = 4;
norm_ = "norm2";
z_k = Multiframe_SR(image_frame(1:12,:,:),image_motion,factor,u_k,lambda,max_iter);

% deblurring
u_k = 0.001;
PSF = 'G_5';
regulor = 'tikhonov';
lambda = 10;
iter = 2000;
% MAP (here since the BSNR is low, means the obeservation is not reliable)
best_fk = hw6_runbest(regulor,z_k,PSF,u_k,lambda,iter,phi);% when using TV set lambda = 0.001

figure()
subplot(1,2,1);imagesc(z_k);title('shift&add');
axis image;colormap gray
subplot(1,2,2);imagesc(best_fk);title('deblurring');
axis image;colormap gray

err = immse(best_fk, g0);
fprintf('\n The MSE of 12 frame n2 reconstruction is %0.4f\n', err);
%% frame number = 1
% solve the shift & add step
u_k = 0.01;
lambda = 0.4;
max_iter = 2000;
factor = 4;
norm_ = "norm2";
z_k = Multiframe_SR(image_frame(1,:,:),image_motion,factor,u_k,lambda,max_iter);

% deblurring
u_k = 0.001;
PSF = 'G_5';
regulor = 'tikhonov';
lambda = 50;
iter = 2500;
% MAP (here since the BSNR is low, means the obeservation is not reliable)
best_fk = hw6_runbest(regulor,z_k,PSF,u_k,lambda,iter,phi);% when using TV set lambda = 0.001

figure()
subplot(1,2,1);imagesc(z_k);title('shift&add');
axis image;colormap gray
subplot(1,2,2);imagesc(best_fk);title('deblurring');
axis image;colormap gray

err = immse(best_fk, g0);
fprintf('\n The MSE of 1 frame n2 reconstruction is %0.4f\n', err);