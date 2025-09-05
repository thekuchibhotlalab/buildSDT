function color = matlabColors(i, colorAlpha)

colors = cat(1,[0, 0.4470, 0.7410],...	          	
[0.8500, 0.3250, 0.0980],...	          	
[0.9290, 0.6940, 0.1250],...	          
[0.4940, 0.1840, 0.5560],...	          
[0.4660, 0.6740, 0.1880],...	          	
[0.3010, 0.7450, 0.9330],...	          
[0.6350, 0.0780, 0.1840]);

if i<=7
    color = colors(i,:);
else
    temp1 = mod(i,6); if temp1==0; temp1=6; end
    temp2 = floor((i-1)/6); if temp1>=temp2; temp1 = temp1+1; end 
    color = (matlabColors(temp1) + matlabColors(temp2))/2;
end 

if exist('colorAlpha')
    color = fn_colorAlpha(color,colorAlpha);   
end

color(color>1) = 1; color(color<0) = 0; 
end


