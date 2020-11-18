%% BME.544.01 - HW1 - Xing Yao
%% Different display functions
clc;    
close all;  
clear; 
cells = load("cell_profile.mat");
figure()
% imagesc
subplot(1,2,1)
imagesc(cells.cell_profile)
colormap(gray)
title("imagesc")
subplot(1,2,2)
imhist(cells.cell_profile,gray)
title("hist")

figure()
%imshow
subplot(2,4,1);
imshow(cells.cell_profile)
title("imshow")
subplot(2,4,5)
imhist(cells.cell_profile,gray)
title("imshow hist")

%imshow [0,255]
subplot(2,4,2);
imshow(cells.cell_profile,[0,255])
title("[0,255]")
subplot(2,4,6)
imhist(cells.cell_profile,gray)
title("[0,255] hist")

%uint8
subplot(2,4,3);
imshow(uint8(cells.cell_profile))
title("uint8")
subplot(2,4,7)
imhist(uint8(cells.cell_profile),gray)
title("uint8 hist")

%mat2gray
subplot(2,4,4);
imshow(mat2gray(cells.cell_profile))
title("mat2gray")
subplot(2,4,8)
imhist(mat2gray(cells.cell_profile))
title("mat2gray hist")

% Here we use both imagesc and imshow to display the image and try
% different methods to convert the original image into grayscale.
% The results illustrate that after being converted into integer
% or [0, 1], the histgrams of image are changed slightly.
% Also, the reason why first imshow picture is blank is because 
% the default value range of imshow is [0, 1], however, all the pixel 
% values in the image exceed 1 and make the whole image a bright area.
% In the following questions, the image is converted via uint8 and display 
% by imagesc.

%% Globel Histgram Equalization
clc;
close all;
clear;
cells = load("cell_profile.mat");
A = uint8(cells.cell_profile);

figure()
subplot(1,2,1)
imagesc(A)
title("Orignal Image")
subplot(1,2,2)
hm_A = histeq(A);
imagesc(hm_A)
title("After Globel Histeq")

figure()
title("Histgram before/after Histeq")
subplot(2,1,1)
imhist(A,gray)
title("Orignal PDF")
subplot(2,1,2)
imhist(hm_A,gray)
title("After Globel Histeq")

% The globel histgram equalization is modifying the pixels via a 
% transformation function based on the intensity distribution of the 
% entire image. However, according to the results, this method failed to 
% enhance the detial in some small areas. In this case, the local histeq 
% is introduced to solve the problem.

%% Local Histgram Equalization
clc;    
close all;  
clear; 
cells = load("cell_profile.mat");
cells_r = uint8(cells.cell_profile);
cells_c = uint8(cells.cell_profile);
for i = 1:size(cells_r,1)
    cells_r(i,:) = histeq(cells_r(i,:));
    cells_c(:,i) = histeq(cells_c(:,i));
end
figure()
subplot(1,2,1)
imagesc(cells.cell_profile)
colorbar
title("Original Image")
subplot(1,2,2)
imagesc(cells_r)
colorbar
title("Image after raw histeq")

figure()
subplot(2,1,1)
imhist(uint8(cells.cell_profile), gray);
title("PDF for original")
subplot(2,1,2)
imhist(cells_r, gray);
title("PDF after raw histeq")

% Since we have a prior knowledge: each row of the image represent the
% potential change of a cell over time, which means every row should be
% regarded as a whole for analysis and pixels in different rows are
% irrelative to each other. Therefore, we apply histeq to every row of the
% image to enhance the details. From the result it's easy to see the 
% activity change of cells after the stimulus. The cells from 602 - 628
% have 3 activity periods after 300 ms and may have the largest change in
% the potential according to the intensity.

% Later, in order to prove the statement that "pixels in different 
% rows are irrelative to each other", a local histeq is also 
% applied on each column.

% As we expect, it has a very similar result as the globel histeq.
% Therefore, we may conclude that the horizontal local histeq is better 
% than the globel and vertical histeq in this specific task. 

figure()
subplot(1,2,1)
imagesc(cells.cell_profile)
colorbar
title("Original Imgae")
subplot(1,2,2)
imagesc(cells_c)
colorbar
title("Image after colume histeq")

figure()
subplot(2,1,1)
imhist(uint8(cells.cell_profile), gray);
title("PDF for original")
subplot(2,1,2)
imhist(cells_c, gray);
title("PDF after column histeq")

%% Local Histeq, block by block

clc;    
close all;  
clear;  
% workspace;  
% format long g;
% format compact;
% fontSize = 20;

% Here we also try a more universal way to solve the problem (assuming 
% there is no prior knowledge).

% the basic idea of the block-by-block local histeq is 1) using a sliding
% window to go through the image with a step of pixel; 2) for each window, 
% we do histeq to the origin(center) pixel with its "neighbor", and then
% assign the transformed value to only the origin pixel.

% A = load("cell_profile.mat");
% A = uint8(A.cell_profile);
A = im2double(imread('block2.jpg')); 
A = rgb2gray(A);

%A = uint8(A);
% if we don't do that, black and white will be inversed
%A = double(A); 

Wsize = 11;%define the window size
n = floor(Wsize/2); % half length of window

% An empty array to store the final results
local_histeq_Img = zeros(size(A,1),size(A,2));

for center_r=1+n:size(A,1)-n
  for center_c=1+n:size(A,2)-n
      
    %calculate the neighbor area 
    %[center_r-n:center_r+n,center_c-n:center_c+n] 
    %for different center [center_r,center_c]
    if center_r-n <=1
      rowstart=1;
      rowend=center_r+n;
    else 
      rowstart=center_r-n;
      if n+center_r >= size(A,1)% consider the boundary
        rowend=size(A,1);
      else
        rowend=center_r+n;
      end
    end
    
    if center_c-n <= 1
      col_start=1;
      col_end=center_c+n;
    else
      col_start=center_c-n;
      if center_c+n > size(A,2)
        col_end=size(A,2);
      else
        col_end=center_c+n;
      end
    end
    
    % generate histgram p(r) for the neighbor
    neighbors = A(rowstart:rowend, col_start:col_end);
    p_r = imhist(neighbors,256); % if using gray will out of range
    % we apply s = T(r) = sum p(r) from 1 to r
    % Now cdf(r) = T(r), r = 0 ~ 255
    s_ = cumsum(p_r); % if we transform to 0-255, the color will inverse
    % normalization
    s_ = s_./s_(end);
    
    
    % Get the original value of the central pixel that we need to replace.
    original_center = A(center_r, center_c);
    % transform the intensity to 0-255, here is the key!! not 255 but 256
    gray_scale = ceil(256 * original_center); 
    % Now map r to s, using T(r) = cdf
    if gray_scale ==0
        gray_scale = 1;
    end
    new_center = s_(gray_scale);
    % assign this value to the center pixel of the window
    local_histeq_Img(center_r,center_c) = new_center;
  end
end

figure()
subplot(1,2,1);
imshow(A);
title("Original Image")
axis on;
subplot(1,2,2);
imshow(local_histeq_Img);
title("Image after block-to-block local histeq")
axis on;

% During this process, we can also answer a question ased by a student
% in the class: why the local histeq results is so "pale"? The reason 
% comes from 2 parts: 1) The color of this picture is very simple, 
% theoretically we have 256 gray scales, but the gray values of the  
% picture itself only accounts for a small part of them, which leads to a 
% very sparse histgram. 2) every time we do the job in a small window,  
% which exacerbates the situation mentioned above.  

% For example, we have a 11*11 window on a area where all the pixels' 
% value are 80. When we calculate the s = T(r), we will see that the r=80  
% is mapped to s = 255 * 1, which means the center pixel of this area
% will have the brightest intensity. This is exactly the same situation we 
% face in this picture and the image we see in the class, and the reason 
% why the result is so "pale" is because nearly all the pixels in one 
% window share the same value and are transformed to very high intensity 
% after histeq.

% Consequently, we can also draw a conclusion that the block-by-block local
% histeq is not suitable for this image, since it diminishes the change of
% pintensity in different stages.


%% 
clc;    
close all;  
clear;  
workspace;  
format long g;
format compact;
fontSize = 20;

% the basic idea of the block-by-block local histeq is 1) using a sliding
% window go through the image with a step of pixel; 2) for each window, we
% do histeq to the origin(center) pixel with its "neighbor", and then assign
% the transformed value to only the origin pixel.

A = load("cell_profile.mat");
A = uint8(A.cell_profile);
% if we don't do that, black and white will be inversed, explain later
A = A/255; 
subplot(1,2,1);
imshow(A);
axis on;
drawnow;

Wsize = 11;%define the window size
n = floor(Wsize/2); % half length of window

% An empty array to store the final results
local_histeq_Img = zeros(size(A,1),size(A,2));

for center_r=1+n:size(A,1)-n
  for center_c=1+n:size(A,2)-n
      
    %calculate the neighbor area [center_r-n:center_r+n, center_c-n:center_c+n] 
    %for different center [center_r,center_c]
    if center_r-n <=1
      rowstart=1;
      rowend=center_r+n;
    else 
      rowstart=center_r-n;
      if n+center_r >= size(A,1)% consider the boundary
        rowend=size(A,1);
      else
        rowend=center_r+n;
      end
    end
    
    if center_c-n <= 1
      col_start=1;
      col_end=center_c+n;
    else
      col_start=center_c-n;
      if center_c+n > size(A,2)
        col_end=size(A,2);
      else
        col_end=center_c+n;
      end
    end
    
    % generate histgram p(r) for the neighbor
    neighbors = A(rowstart:rowend, col_start:col_end);
    p_r = imhist(neighbors,gray)/(Wsize^2); % normalization
    % we apply s = T(r) = sum p(r) from 1 to r
    % Now cdf(r) = T(r), r = 1 ~ 256
    cdf = cumsum(p_r)*255; 
    
    % Get the original value of the central pixel that we need to replace.
    original_center = A(center_r, center_c);
    % Now map r to s, using T(r) = cdf
    new_center = cdf(original_center);
    % assign this value to the center pixel of the window
    local_histeq_Img(center_r,center_c) = new_center;
  end
end
subplot(1,2,2);
imagesc(local_histeq_Img);
axis on;

% During this process, we can also answer the question ased by a student
% in the class: why the local histeq results is so "pale"? The reason comes
% from 2 parts: 1) The color of this picture is very simple, 
% theoretically we have 256 intervals, but the gray value of the picture 
% itself only accounts for a small part of them, which can be seen from the
% histgram. As a result
%.  2）every time we use a 
% small window to generate the local histgram, and map it into a new [0, ]



