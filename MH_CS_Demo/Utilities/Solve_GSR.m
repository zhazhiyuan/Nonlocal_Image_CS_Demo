% =========================================================================
% GSRC-WNNM for Image Inpainting, Version 1.0
% Copyright(c) 2016 Zhiyuan Zha,  Xin Liu, Ziheng Zhou, Jingang Shi, Shouren Lan, Yang Chen, Yechao Bai, Qiong Wang, Lan Tang and Xinggan Zhang
% All Rights Reserved.
%
% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is here
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%----------------------------------------------------------------------
%

function [Imout] = Solve_GSR(InputImage, Opts)


[H, W]                  =      size(InputImage);

Region                  =      Opts.Region;

patch                   =      Opts.patch;

Patchsize               =      patch*patch;

Sim                     =      Opts.Sim;

step                    =      Opts.step;

N                       =      H-patch+1;

M                       =      W-patch+1;

L                       =      N*M;

row                     =       [1:step:N];

row                     =       [row row(end)+1:N];

col                     =       [1:step:M];

col                     =       [col col(end)+1:M];

Groupset                =       zeros(Patchsize, L, 'single');

cnt                     =         0;

for      i  = 1:patch
    
    for      j  = 1:patch
        
             cnt    =  cnt+1;
             Patch  =  InputImage(i:H-patch+i,j:W-patch+j);
             Patch  =  Patch(:);
             Groupset(cnt,:) =  Patch';
    end
    
end

GroupsetT               =           Groupset';

I                       =           (1:L);

I                       =           reshape(I, N, M);

NN                      =           length(row);

MM                      =           length(col);

Imgtemp                 =            zeros(H, W);

Imgweight               =            zeros(H, W);

Array_Patch             =            zeros(patch, patch, Sim);


for  i  =  1 : NN
    
    for  j  =  1 : MM
        
           currow              =              row(i);
           
            curcol             =              col(j);
            
             off               =              (curcol-1)*N + currow;
      
            Patchindx          =               Similar_Search(GroupsetT, currow, curcol, off, Sim, Region, I);
        
            curArray           =               Groupset(:, Patchindx);
        
             M_temp            =               repmat(mean(curArray,2),1,Sim);
        
             curArray          =               curArray-M_temp;
        
            U_i                =               getsvd(curArray); % generate PCA basis
        
            A0                 =               U_i'*curArray;
        
            s0                 =               mean (A0.^2,2);

            s0                 =               max  (0, s0-Opts.sigma^2);    
            
            lambda             =               repmat ( 2*sqrt(2)*Opts.sigma^2./(sqrt(s0)+eps),[1, size(A0,2)]); %Generate the weight Eq.(19)
        
             tau               =               lambda*step*Sim/(Opts.mu2);

            Thre               =               sqrt(2*tau);
        
           Alpha               =               A0.*(abs(A0)>Thre);  % L0_norm

          curArray             =               U_i*Alpha   +   M_temp;
            
        
        for k = 1:Sim
            
            Array_Patch(:,:,k) = reshape(curArray(:,k),patch,patch);
            
        end
        
        for k = 1:length(Patchindx)
            
            RowIndx  =  ComputeRowNo((Patchindx(k)), N);
            
            ColIndx  =  ComputeColNo((Patchindx(k)), N);
            
            Imgtemp(RowIndx:RowIndx+patch-1, ColIndx:ColIndx+patch-1)    =   Imgtemp(RowIndx:RowIndx+patch-1, ColIndx:ColIndx+patch-1) + Array_Patch(:,:,k)';
         
            Imgweight(RowIndx:RowIndx+patch-1, ColIndx:ColIndx+patch-1)  =   Imgweight(RowIndx:RowIndx+patch-1, ColIndx:ColIndx+patch-1) + 1;
        
        end
        
    end
    
end

Imout = Imgtemp./(Imgweight+eps);

return;



