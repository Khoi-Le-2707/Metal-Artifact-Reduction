function Extended_sinogram = symmetric_mirroring(sinogram,W)

n = size(sinogram,2);
m = size(sinogram,1);
view = size(sinogram,3);

Extended_sinogram = zeros(m,n+2*W,view);
Extended_sinogram(:,W+1:W+n,:) = sinogram;
Extended_sinogram(:,1:W,:) = max(sin((0:W-1)*pi/(2*(W-1))).*(2*sinogram(:,1,:)-sinogram(:,W+1-(1:W),:)),0);
Extended_sinogram(:,W+n+1:2*W+n,:) = max(cos((0:W-1)*pi/(2*(W-1))).*(2*sinogram(:,n,:)-sinogram(:,n-(0:W-1),:)),0);

end