function output2=My_adaptivemean2(input,Wsize)

[r, c]=size(input);

% generate a sample for calculation
output=zeros(r+2*Wsize+1,c+2*Wsize+1);
output(Wsize+1:r+Wsize,Wsize+1:c+Wsize)=input;

% % save the real output
% output2=zeros(r+2*Wsize+1,c+2*Wsize+1);
% output2(Wsize+1:r+Wsize,Wsize+1:c+Wsize)=input;

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

% % Here actually we can determine the sigma via calculate the 
% [x,y] = meshgrid(-Wsize:Wsize,-Wsize:Wsize);
% % generate spatial filter
% w1=exp(-(x.^2+y.^2)/(2*sigma_s^2));  
% global std:
std_global = std2(input);

% if directly operator on the output, the variance of local will decrease
% and lead to more mean
for i=Wsize+1:r+Wsize
    for j=Wsize+1:c+Wsize        
        std_local = std2(output(i-Wsize:i+Wsize,j-Wsize:j+Wsize));
        k_parameter = (std_global/std_local)^2;
        if k_parameter > 1
            k_parameter = 1;
        end
        m = mean(mean(output(i-Wsize:i+Wsize,j-Wsize:j+Wsize)));        
        output(i,j) = output(i,j) - k_parameter.*(output(i,j) - m);
    end
end

output2 = output(Wsize+1:r+Wsize,Wsize+1:c+Wsize);

end