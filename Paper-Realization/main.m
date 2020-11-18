%% (a)
clear;
close all;
clc

im = double(imread('ConeImage.tif'));
im_fft = log(abs(fftshift(fft2(im))));

figure()
subplot(1,2,1)
imshow(im,[]);title('Original Image');xlabel("pixel");axis on; 
subplot(1,2,2)
imshow(im_fft,[]);title('Log(FFT Intensity)');xlabel("fc: pixel/105.92um");axis on; 
ax = gca;ax.XTick = [1,50,100,150,200];ax.YTick = [1,50,100,150,200];
ax.XTickLabel = {-100,-50,0,50,100};ax.YTickLabel = {100,50,0,-50,-100};

%% (d)
% bandpass filter
B_F = createCirclesMask([200,200],[101,101],15) -  ...
    createCirclesMask([200,200],[101,101],8);
% filter the image
im_BF_F = fftshift(fft2(im)).*B_F;
im_BF = real(ifft2(ifftshift(im_BF_F)));
% the removed part
im_res = im - im_BF;
%
figure()
subplot(2,2,1);imshow(im,[]);title('Original Image');
subplot(2,2,2);imshow(B_F);title('Band Pass filter');axis on; 
ax = gca;ax.XTick = [1,50,100,150,200];ax.YTick = [1,50,100,150,200];
ax.XTickLabel = {-100,-50,0,50,100};ax.YTickLabel = {100,50,0,-50,-100};
subplot(2,2,3);imshow(im_BF,[]);title('Filtered Image');
subplot(2,2,4);imshow(im_res,[]);title('Removed Part')

%% (e)
annotation = csvread('Manual Coordinates.csv');

% Built a matched filter: 1) half white half black; 2) high pass; 
% 3) consider the convolution as filp, so the white and black should be 
% inversed
% The smaller the kernal, the more edge is detected, increase
% the False Positive rate; the larger the kernal, the higher the FN rate
M_filter = ones(6,6);
M_filter(:,round(size(M_filter,1)/2)+1:end) = -1;

% find the location of local_max, since the x axis is column
[detected_location(:,2),detected_location(:,1)] =  ...
    find(imregionalmax(imfilter(im_BF,M_filter,'replicate','same','conv'))==1);

% calculate density
D_anno = size(annotation,1)*1000^2/(105.92^2);
D_detected = size(detected_location,1)*1000^2/(105.92^2);

figure()
imshow(im,[]);title("Annotation(green) and Detection(red)");hold on;
scatter(annotation(:,1),annotation(:,2),10,'g','filled')
scatter(detected_location(:,1),detected_location(:,2),10,'r','filled')
hold off;

n_a = ['The number of manurally annotated cones is: ', num2str(size(annotation,1))];
n_d = ['The number of detected cones is: ', num2str(size(detected_location,1))];
a_d = ['The annotation density is: ', num2str(D_anno)];
d_d = ['The detected density is: ', num2str(D_detected)];
disp(n_a)
disp(n_d)
disp(a_d)
disp(d_d)

%% test other filter
clear;
close all;
clc

im = double(imread('ConeImage.tif'));

% bandpass filter
B_F = createCirclesMask([200,200],[101,101],15) -  ...
    createCirclesMask([200,200],[101,101],8);
% filter the image
im_BF_F = fftshift(fft2(im)).*B_F;
im_BF = real(ifft2(ifftshift(im_BF_F)));
annotation = csvread('Manual Coordinates.csv');

% Built a matched filter: 1) half white half black; 2) high pass; 
% 3) consider the convolution as filp, so the white and black should be 
% inversed
% The smaller the kernal, the more edge is detected, increase
% the False Positive rate; the larger the kernal, the higher the FN rate
M_filter = ones(8,8);
M_filter(:,round(size(M_filter,1)/2)+1:end) = -1;

% find the location of local_max, since the x axis is column
[detected_location(:,2),detected_location(:,1)] =  ...
    find(imregionalmax(imfilter(im_BF,M_filter,'replicate','same','conv'))==1);

figure()
imshow(im,[]);title("Annotation(green) and Detection(red)");hold on;
scatter(annotation(:,1),annotation(:,2),10,'g','filled')
scatter(detected_location(:,1),detected_location(:,2),10,'r','filled')
hold off;

n_a = ['The number of manurally annotated cones is: ', num2str(size(annotation,1))];
n_d = ['The number of detected cones is: ', num2str(size(detected_location,1))];
disp(n_a)
disp(n_d)