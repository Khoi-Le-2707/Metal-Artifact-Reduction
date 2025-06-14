clc; close all; clear;
addpath(genpath("Bilder"))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   FOV based MAR Main Actual Code    %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loading Sinogram
% load sinogram_metal_1
% load sinogram_metal_2
% load sinogram_metal_3

%% My_Code: 1) Import & downsample raw sinogram -----------------------------------
rawFile = 'Bilder/training_body_metalart_sino11001_900x1000.raw';
fid     = fopen(rawFile,'rb');
sino2D  = fread(fid,[900,1000],'float32=>single');   % [Detector , Projection]
fclose(fid);

%% 1b) Adjust orientation (as in ImageJ style)
% sino2D = rot90(flipud(fliplr(sino2D.')),2);   % transpose → mirror horizontally → mirror vertically

%%2) Scale down to 420 × 720
% % - bilinear is sufficiently fast; bicubic also works
% sino2D_rs = imresize(sino2D,[420 720],'bilinear');   % [Detector , Projekcion]

%% Plot to check: %% Display both sinograms
figure;
% subplot(1,2,1);
imagesc(sino2D); 
colormap gray; 
axis image; 
title('Original Sinogram (900x1000)');
xlabel('Projections'); ylabel('Detector Pixels');

% subplot(1,2,2);
% imagesc(sino2D_rs); 
% colormap gray; 
% axis image; 
% title('Resized Sinogram (420x720)');
% xlabel('Projections'); ylabel('Detector Pixels');


%% 3) Bring to 3D format 10 × 900 × 1000
nSlices   = 10;
sino3D    = zeros(nSlices,900,1000,'single');
for k = 1:nSlices
    sino3D(k,:,:) = sino2D;      % same slice copied 10 times
end

%% 4) Name variable & file exactly as original
sinogram = sino3D;                  % Name, which Main.m expects
save('temp_sinogram.mat','sinogram');  % overwrites/replaces test file

%% 2) Use original pipeline unchanged -----------------------

sino_ori = single(sinogram(:,:,:));

for i = 1 : 10 % make FOV region of reconstruction image
fov_region(:,:,i) = makecircle(zeros(512),512/2,512/2,512/2,512/2,1);
end

parameter % loading geometry of system

%% STEP 1 : Truncation Correction

sino_ori_ex = symmetric_mirroring(sino_ori,100);
img_ori = FDK((single(sino_ori_ex)),geo_ex,angles,'filter','hann').*fov_region;
angles_fov = angles;
figure;
imagesc(img_ori(:,:,5)); 
colormap gray; 
colorbar;
axis image;
title('reconstructed image (img\_ori)');


%% STEP 2 : Synthesizing FOV based sinogram by truncation corrected image
sino_fov = Ax(single(img_ori),geo_fov,angles_fov,'interpolated');

%% STEP 3 : Sinogram Inpainting based MAR
%% Linear MAR
metal_seg = [img_ori>0.045]; % Metal Segmentation
se = strel('disk',2,0);
img_metal = imdilate(metal_seg,se);

metal_sino = Ax(single(img_metal),geo,angles,'interpolated'); % Obtained metal sinogram
metal_sino_fov = Ax(single(img_metal),geo_fov,angles_fov,'interpolated'); % Obtained metal sinogram

mar_sino_ori = LMAR(sino_ori,metal_sino); % Linear MAR process
mar_sino_fov = LMAR(sino_fov,metal_sino_fov); % Linear MAR process

mar_sino_ori_ex = symmetric_mirroring(mar_sino_ori,100); % Previous method truncation artifact correction
img_lmar_ori = FDK(single(mar_sino_ori_ex),geo_ex,angles,'filter','hann').*fov_region; % Reconstruction of LMAR previous method
img_lmar_fov = FDK(single(mar_sino_fov),geo_fov,angles_fov,'filter','hann').*fov_region; % Reconstruction of LMAR proposed method

figure; imshow(abs([img_lmar_ori(:,:,5) img_lmar_fov(:,:,5)]),[0 0.03])

%% Normalized MAR
%% Prior Image and Sinogram
prior_img_ori = img_lmar_ori;
prior_img_fov = img_lmar_fov;

n = 2;
H = fspecial('gaussian',n,n);
blur_ori = imfilter(img_lmar_ori,H);
prior_img_ori([blur_ori<0.04 & blur_ori>0.0001]) = 0.02; % Values below T1(=0.04) fill the avarage value of the soft tissue
prior_img_ori([blur_ori<0.0001]) = 0; % Exclude the air area

n = 2;
H = fspecial('gaussian',n,n);
blur_fov = imfilter(img_lmar_fov,H);
prior_img_fov([blur_fov<0.04 & blur_fov>0.0001]) = 0.02; % Values below T1(=0.04) fill the avarage value of the soft tissue
prior_img_fov([blur_fov<0.0001]) = 0; % Exclude the air area

prior_sino_ori = Ax(single(prior_img_ori),geo,angles,'interpolated'); % create prior sinogram for previous method
prior_sino_fov = Ax(single(prior_img_fov),geo_fov,angles_fov,'interpolated'); % create prior sinogram for proposed method

%% NMAR
nmar_sino_ori = NMAR(sino_ori,prior_sino_ori,metal_sino); % NMAR process for previous method
nmar_sino_fov = NMAR(sino_fov,prior_sino_fov,metal_sino_fov); % NMAR process for proposed method

nmar_sino_ori_ex = symmetric_mirroring(nmar_sino_ori,100); % Previous method truncation artifact correction
img_nmar_ori = FDK(single(nmar_sino_ori_ex),geo_ex,angles,'filter','hann').*fov_region; % Reconstruction of LMAR previous method
img_nmar_fov = FDK(single(nmar_sino_fov),geo_fov,angles_fov,'filter','hann').*fov_region; % Reconstruction of LMAR proposed method

%% Figuring
A = img_lmar_ori(:,:,5)+img_metal(:,:,5);
B = img_lmar_fov(:,:,5)+img_metal(:,:,5);
C = img_nmar_ori(:,:,5)+img_metal(:,:,5);
D = img_nmar_fov(:,:,5)+img_metal(:,:,5);
imshow(1000*([A B C D]-0.02)/0.02,[-1000 1000])

