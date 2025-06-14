% ---------- Sinogramm laden (900 Detektorpixel × 1000 Projektionen) ----------
fid   = fopen('Bilder/training_body_metalart_sino11001_900x1000.raw','rb');
sino  = fread(fid,[1000,900],'float32')';   % Detektor = Zeilen (900×1000)
fclose(fid);

% ---------- Winkelvektor ----------
theta = linspace(0,360,1000+1);  theta(end)=[];  % 0 … 359.64 °

% ---------- 2-D-Fan-Beam-FBP (Ram-Lak-Filter) ----------
img2D = iradon(sino, theta, 'linear', 'Ram-Lak', 1, 512);   % 512×512 Pixel

imshow(img2D,[]); title('Fan-Beam FBP (512×512)');
