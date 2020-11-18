%% Image 1 : camera man, BSNR40dB
clc;
clear;
close all;

% import images
g0 = imread('cameraman_Original.tif');
g = imread('cameraman_19x19_BSNR40dB_RMSE296733.png'); % g 

% set parameters
u_k = 1;
PSF = 'U_19';
regulor = 'tikhonov';
lambda = 0.000001;
iter = 3000;
% MAP (here since the BSNR is high, means the obeservation is reliable)
best_fk = runbest(regulor,g,PSF,u_k,lambda,iter);% when using TV set lambda = 0.001

% show the deblurring result
figure(1);subplot(1,3,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,3,2);imshow(g);title('Before Deblurring');
axis image;colormap gray
subplot(1,3,3);imagesc(best_fk);title('After Deblurring');
axis image;colormap gray

%% Image 2 : camera man, BSNR25dB
clc;
clear;
close all;

% import images
g0 = imread('cameraman_Original.tif');
g = imread('cameraman_19x19ave_BSNR25dB_RMSE298183.png'); % g 

% set parameters
u_k = 1;
PSF = 'U_19';
regulor = 'tikhonov';
lambda = 0.01;
iter = 2000;
% MAP (here since the BSNR is low, means the obeservation is not reliable)
best_fk = runbest(regulor,g,PSF,u_k,lambda,iter);% when using TV set lambda = 0.001

% 
figure(1);subplot(1,3,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,3,2);imshow(g);title('Before Deblurring');
axis image;colormap gray
subplot(1,3,3);imagesc(best_fk);title('After Deblurring');
axis image;colormap gray
%% Image 3: Lena, BSNR15dB
clc;
clear;
close all;

% import images
g0 = imread('lena_Original.png');
g = imread('lena_5x5Ga15_BSNR15dB_RMSE107794.png'); % g 

% set parameters
u_k = 0.001;
PSF = 'G_5';
regulor = 'tikhonov';
lambda = 1; % since BSNR is too small, obeservation is not reliable
iter = 1500;
% MAP
best_fk = runbest(regulor,g,PSF,u_k,lambda,iter);% when using TV set lambda = 0.001

% 
figure(1);subplot(1,3,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,3,2);imshow(g);title('Before Deblurring');
axis image;colormap gray
subplot(1,3,3);imagesc(best_fk);title('After Deblurring');
axis image;colormap gray

%% Image 4: ChemicalPlant BSNR 30
clc;
clear;
close all;

% import images

g0 = imread('ChemicalPlant256_Original.png');
g = imread('ChemicalPlant256_11x11Ga175_BSNR30_RMSE150852.png'); % g 

% set parameters
BSNR = 40;
u_k = 0.5;
PSF = 'G_11';
lambda = 0.001;
%regulor = 'TV';
regulor = 'tikhonov';
iter = 1000;
% MAP
best_fk = runbest(regulor,g,PSF,u_k,lambda,iter);% when using TV set lambda = 0.001

%
figure(1);subplot(1,3,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,3,2);imshow(g);title('Before Deblurring');
axis image;colormap gray
subplot(1,3,3);imagesc(best_fk);title('After Deblurring');
axis image;colormap gray

%% 

%% Image 3: Lena, BSNR15dB
clc;
clear;
close all;

% import images
g0 = imread('lena_Original.png');
g = imread('lena_5x5Ga15_BSNR15dB_RMSE107794.png'); % g 
g1 = imread('lena_orig.png');
g1 = rgb2gray(g1);
g1 = imresize(g1, [512,512]);

% % set parameters
% u_k = 0.001;
% PSF = 'G_5';
% regulor = 'tikhonov';
% lambda = 1; % since BSNR is too small, obeservation is not reliable
% iter = 1500;
% % MAP
% best_fk = runbest(regulor,g,PSF,u_k,lambda,iter);% when using TV set lambda = 0.001

% 
figure(1);subplot(1,3,1);imagesc(g0);title('Original Image');
axis image;colormap gray
subplot(1,3,2);imshow(g);title('Before Deblurring');
axis image;colormap gray
subplot(1,3,3);imagesc(g1);title('After Deblurring');
axis image;colormap gray