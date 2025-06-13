%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%   Normalized MAR   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Normalized MAR code

function [corrected_sino] = NMAR(uncorrected_sino,prior_sino,metal_sino)

if size(uncorrected_sino,3)==1
    corrected_sino = (real_NMAR(uncorrected_sino',prior_sino',metal_sino'))';
else
    corrected_sino = zeros(size(uncorrected_sino));
    for ii = 1 : size(uncorrected_sino,3)
       corrected_sino(:,:,ii) = (real_NMAR(uncorrected_sino(:,:,ii)',prior_sino(:,:,ii)',metal_sino(:,:,ii)'))'; 
    end
    
end
end




function [corrected_sino] = real_NMAR(uncorrected_sino,prior_sino,metal_sino)


prior_sino = double(prior_sino);
uncorrected_sino = double(uncorrected_sino);
metal_seg = logical(metal_sino);

if sum(sum(metal_seg))==0
    corrected_sino = uncorrected_sino;
else
    
    k = 0.000001; % non zero index
    normalized_sino = (uncorrected_sino) ./ (prior_sino + k);
    
    S_m = double(logical(metal_seg));
    E_m = S_m;
    S_m = S_m - [zeros(1,size(S_m,2)); S_m(1:end-1,:)];
    E_m = E_m - [E_m(2:end,:); zeros(1,size(S_m,2))];
    
    st = find(S_m == 1);
    [st_x st_y] = find(S_m == 1);
    ed = find(E_m == 1);
    [ed_x ed_y] = find(E_m == 1);
    
    interpol_sino = normalized_sino;
    for i = 1 : size(st,1)
        if st_x(i)==1
            interpol_sino(st(i):ed(i)) = interpol_sino(ed(i)+1);
        elseif ed_x(i)==size(S_m,1)
            interpol_sino(st(i):ed(i)) = interpol_sino(st(i)-1);
        else
            interpol_sino(st(i):ed(i)) = interp1([st(i)-1 ed(i)+1],[interpol_sino(st(i)-1) interpol_sino(ed(i)+1)],st(i):ed(i));
        end
    end
    
    corrected_sino = interpol_sino .* (prior_sino + k); % not yet replace metal image
    
end

end