clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

files = dir([sourcePath,'\*.mat']);

%%% initialization
popularity = 0;
intensity.m1.MSO = 0; intensity.m2.MSO = 0; intensity.m3.MSO = 0;
intensity.m1.MBO = 0; intensity.m2.MBO = 0; intensity.m3.MBO = 0;
intensity.m1.LSO = 0; intensity.m2.LSO = 0; intensity.m3.LSO = 0;
intensity.m1.LBO = 0; intensity.m2.LBO = 0; intensity.m3.LBO = 0;
intensity.m1.SCancel = 0; intensity.m2.SCancel = 0; intensity.m3.SCancel = 0;
intensity.m1.BCancel = 0; intensity.m2.BCancel = 0; intensity.m3.BCancel = 0;

for i = 1:length(files)

    load(files(i).name)
    popularity = popularity + length(data.time);
    %%% 1st moment
    intensity.m1.MSO = intensity.m1.MSO + mean(data.MSO)*length(data.time);
    intensity.m1.MBO = intensity.m1.MBO + mean(data.MBO)*length(data.time);
    intensity.m1.LSO = intensity.m1.LSO + mean(data.LSO(:,1:5))*length(data.time);
    intensity.m1.LBO = intensity.m1.LBO + mean(data.LBO(:,1:5))*length(data.time);
    intensity.m1.SCancel = intensity.m1.SCancel + mean(data.SCancel(:,1:5))*length(data.time);
    intensity.m1.BCancel = intensity.m1.BCancel + mean(data.BCancel(:,1:5))*length(data.time);
    
    %%% 2nd moment
    intensity.m2.MSO = intensity.m2.MSO + mean(data.MSO.^2)*length(data.time);
    intensity.m2.MBO = intensity.m2.MBO + mean(data.MBO.^2)*length(data.time);
    intensity.m2.LSO = intensity.m2.LSO + mean(data.LSO(:,1:5).^2)*length(data.time);
    intensity.m2.LBO = intensity.m2.LBO + mean(data.LBO(:,1:5).^2)*length(data.time);
    intensity.m2.SCancel = intensity.m2.SCancel + mean(data.SCancel(:,1:5).^2)*length(data.time);
    intensity.m2.BCancel = intensity.m2.BCancel + mean(data.BCancel(:,1:5).^2)*length(data.time);
    
    %%% 3rd moment
    intensity.m3.MSO = intensity.m3.MSO + mean(data.MSO.^3)*length(data.time);
    intensity.m3.MBO = intensity.m3.MBO + mean(data.MBO.^3)*length(data.time);
    intensity.m3.LSO = intensity.m3.LSO + mean(data.LSO(:,1:5).^3)*length(data.time);
    intensity.m3.LBO = intensity.m3.LBO + mean(data.LBO(:,1:5).^3)*length(data.time);
    intensity.m3.SCancel = intensity.m3.SCancel + mean(data.SCancel(:,1:5).^3)*length(data.time);
    intensity.m3.BCancel = intensity.m3.BCancel + mean(data.BCancel(:,1:5).^3)*length(data.time);
    
end

intensity.m1.MSO = intensity.m1.MSO/popularity;
intensity.m1.MBO = intensity.m1.MBO/popularity;
intensity.m1.LSO = intensity.m1.LSO/popularity;
intensity.m1.LBO = intensity.m1.LBO/popularity;
intensity.m1.SCancel = intensity.m1.SCancel/popularity;
intensity.m1.BCancel = intensity.m1.BCancel/popularity;

intensity.m2.MSO = intensity.m2.MSO/popularity;
intensity.m2.MBO = intensity.m2.MBO/popularity;
intensity.m2.LSO = intensity.m2.LSO/popularity;
intensity.m2.LBO = intensity.m2.LBO/popularity;
intensity.m2.SCancel = intensity.m2.SCancel/popularity;
intensity.m2.BCancel = intensity.m2.BCancel/popularity;

intensity.m3.MSO = intensity.m3.MSO/popularity;
intensity.m3.MBO = intensity.m3.MBO/popularity;
intensity.m3.LSO = intensity.m3.LSO/popularity;
intensity.m3.LBO = intensity.m3.LBO/popularity;
intensity.m3.SCancel = intensity.m3.SCancel/popularity;
intensity.m3.BCancel = intensity.m3.BCancel/popularity;

A = [intensity.m1.MSO, intensity.m1.MBO, intensity.m1.LSO, intensity.m1.LBO, ...
    intensity.m1.SCancel, intensity.m1.BCancel];
B = [intensity.m2.MSO, intensity.m2.MBO, intensity.m2.LSO, intensity.m2.LBO, ...
    intensity.m2.SCancel, intensity.m2.BCancel];
C = [intensity.m3.MSO, intensity.m3.MBO, intensity.m3.LSO, intensity.m3.LBO, ...
    intensity.m3.SCancel, intensity.m3.BCancel];

sol = zeros(3,size(A,2));
for i = 1:size(A,2)
    syms lamda alpha beta
    [sollamda, solalpha, solbeta] = solve( ...
        lamda*0.5*alpha/beta == A(i), ...
        alpha*(alpha+1)*lamda*0.5/beta^2 + A(i)*lamda*0.5*alpha/beta == B(i), ...
        2*A(i)*alpha*(alpha+1)*lamda*0.5/beta^2 + alpha*(alpha+1)*(alpha+2)*lamda*0.5/beta^3 + B(i)*lamda*0.5*alpha/beta == C(i), ...
        lamda,alpha,beta);
    sol(1,i) = double(sollamda);
    sol(2,i) = double(solalpha);
    sol(3,i) = double(solbeta);
    clear lamda alpha beta;
end

intensity.MSO = sol(:,1);
intensity.MBO = sol(:,2);
intensity.LSO = sol(:,3:7);
intensity.LBO = sol(:,8:12);
intensity.SCancel = sol(:,13:17);
intensity.BCancel = sol(:,18:end);


    
