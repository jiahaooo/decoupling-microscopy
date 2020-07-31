clc
clear
path = 'F:\paper1\data\simulation\';

Files = dir([path,'newset\' '*.tif']);
LengthFiles = length(Files);



h = imreadstack('F:\tool\h488.tif');


for maxhdz = [25 50 100 255 500 1000 2000]
    mkdir([path '未处理的newset\' num2str(maxhdz)]);
    k = 1;
    tic;
    for i = 1:LengthFiles   
        f0 = imreadstack([path 'newset\' Files(i).name]);
        f = (f0.*maxhdz./255);
        g = imfilter(floor(f),h,'conv','same','circular');
        g = imnoise(uint16(g),'poisson');
        g = double(g) + 5*randn(size(f,1),size(f,2));
        g(g<0) = 0;
        g = floor(g);
        if k < 10
            imwritestack(f,[path '未处理的newset\' num2str(maxhdz) '\0' num2str(k) '_f.tif']);
            imwritestack(g,[path '未处理的newset\' num2str(maxhdz) '\0' num2str(k) '_g.tif']);
        else
            imwritestack(f,[path '未处理的newset\' num2str(maxhdz) '\' num2str(k) '_f.tif']);
            imwritestack(g,[path '未处理的newset\' num2str(maxhdz) '\' num2str(k) '_g.tif']);
        end
        k = k+1;
    end
    toc;
end