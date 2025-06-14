%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Make Circle   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simple function to create a circle, to create the FOV area

function output_image = makecircle(input_image,x,y,a,b,d)
A = input_image;
for i = 1 : size(A,1)
    for j = 1 : size(A,2)
        if (i-x)^2/a^2 + (j-y)^2/b^2 < 1
            
                A(i,j) = A(i,j)+d;
            
        end
    end
end
output_image = A;

end