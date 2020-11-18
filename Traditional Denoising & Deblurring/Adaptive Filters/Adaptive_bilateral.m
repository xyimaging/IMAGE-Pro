function output=Adaptive_bilateral(input,sigma_r,sigma_s,Wsize)

[r, c]=size(input);

output=zeros(r+2*Wsize+1,c+2*Wsize+1);
output(Wsize+1:r+Wsize,Wsize+1:c+Wsize)=input;

% To keep the edge information, we padding via repeat the edge
%expand top edge
output(1:Wsize,Wsize+1:c+Wsize)=input(1:Wsize,1:c);             
%right edge
output(1:r+Wsize,c+Wsize+1:c+2*Wsize+1)=output(1:r+Wsize,c:c+Wsize);    
%bottom edge
output(r+Wsize+1:r+2*Wsize+1,Wsize+1:c+2*Wsize+1) ...
    =output(r:r+Wsize,Wsize+1:c+2*Wsize+1);    %bottom edge
%left edge
output(1:r+2*Wsize+1,1:Wsize)=output(1:r+2*Wsize+1,Wsize+1:2*Wsize);       

% Here actually we can determine the sigma via calculate the 
[x,y] = meshgrid(-Wsize:Wsize,-Wsize:Wsize);
% generate spatial filter
w1=exp(-(x.^2+y.^2)/(2*sigma_s^2));  
% global std:
std_global = std2(input);

% while the window moving around the edge, the range filter is generated
for i=Wsize+1:r+Wsize
    for j=Wsize+1:c+Wsize        
        w2=exp(-(output(i-Wsize:i+Wsize,j-Wsize:j+Wsize)- ... 
            output(i,j)).^2/(2*sigma_r^2));
        
        std_local = std2(output(i-Wsize:i+Wsize,j-Wsize:j+Wsize));
        k_parameter = (std_global/std_local)^2;
        if k_parameter > 1
            k_parameter = 1;
        end
        
        % generate the real filter
        w=w1.*w2;
        % apply the filter to the image
        s=output(i-Wsize:i+Wsize,j-Wsize:j+Wsize).*w;
        s=sum(sum(s))/sum(sum(w)); 
        output(i,j) = output(i,j) - k_parameter.*(output(i,j) - s);
    end
end

output = output(Wsize+1:r+Wsize,Wsize+1:c+Wsize);

end