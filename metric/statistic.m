clear; clc; close all;

gt = im2double(imread("ground_truth.png"));
gt = gt(:,:,1);
mask = im2double(imread("metal_mask.png"));
mask = mask(:,:,1);

model_list = ["InDuDoNet", "InDuDoNet+", "OSCNet", "ACDNet", "DICDNet", "SR"];

SSIMs = zeros(1, length(model_list));
PSNRs = zeros(1, length(model_list));

for i = 1:length(model_list) 
    mar_img = im2double(imread(sprintf("%s.png", model_list(i))));
    
    if model_list(i) ~= "SR"
        mar_img = imresize(mar_img, [512 512]); 
    end
    mar_img = mar_img(:,:,1);

    [mssim, ssim_map] = ssim_SDL(mar_img.*(1-mask), gt.*(1-mask));
    SSIMs(i) = mssim;
    
    psnr_val = psnr_SDL(mar_img.*(1-mask), gt.*(1-mask));
    PSNRs(i) = psnr_val;
end

figure
subplot(1,2,1)
b1 = bar(categorical(model_list), SSIMs);
ylim([0 1])
title("SSIM")
grid on

xtips1 = b1.XEndPoints;
ytips1 = b1.YEndPoints;
labels1 = string(round(b1.YData, 4)); % Adjust rounding as needed
text(xtips1, ytips1 + 0.02, labels1, 'HorizontalAlignment','center', 'FontSize',10)

subplot(1,2,2)
b2 = bar(categorical(model_list), PSNRs);
ylim([0 35])
title("PSNR")
ylabel("PSNR in dB")
grid on

xtips2 = b2.XEndPoints;
ytips2 = b2.YEndPoints;
labels2 = string(round(b2.YData, 4)); % Adjust rounding as needed
text(xtips2, ytips2 + 0.5, labels2, 'HorizontalAlignment','center', 'FontSize',10)
