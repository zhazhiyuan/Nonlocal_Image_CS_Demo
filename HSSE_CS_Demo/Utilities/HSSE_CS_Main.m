
function [Reconstructed_image, PSN_Result,FSIM_Result,SSIM_Result, j, Err_or] = HSSE_CS_Main(Y, Opts,err_or)




Row                                  =                               Opts.Row;

Col                                  =                               Opts.Col;

PHI                                  =                               Opts.PHI;

X_org                                =                               Opts.Org;

IterNum                              =                               Opts.IterNum;

X_Initial                            =                               Opts.Initial;

patch_size                           =                               Opts.patch_size;

loop                                 =                                Opts.loop;

mu                                   =                                Opts.mu;

X                                    =                                im2col(X_Initial, [patch_size patch_size], 'distinct');

%W                                    =                                zeros(size(X));

B                                    =                                zeros(size(X));

ATA                                  =                                PHI'*PHI;

ATy                                  =                                PHI'*Y;

IM                                   =                                eye(size(ATA));

All_PSNR                             =                                 zeros(1,IterNum);

 BRM_Results                         =                             cell (1,IterNum);   
 
for j = 1:IterNum
    
    
    X_HAT                            =                                 X;
    

    r                                =                                 col2im(X_HAT, [patch_size patch_size],[Row Col], 'distinct');  
    
    C                                =                                 col2im(B, [patch_size patch_size],[Row Col], 'distinct');     
    
    E_Out                            =                                 Exter_NSS_Main  (r, Opts, 10);   
      
      
    E_Out_New                        =                                 (Opts.alpha * r + Opts.beta*E_Out)/ (Opts.alpha + Opts.beta);     
   
   
   Inter_out                         =                                   Inter_NSS_Core  (E_Out_New, Opts);     
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ADMM%%%%%%%%%%%%%%%%%%%%%%
   
       L                             =                                  (mu*r-mu*C + Opts.alpha* Inter_out)/ (mu+ Opts.alpha);  

    
    W                                =                                   im2col(L, [patch_size patch_size], 'distinct');
    
    
   for jj = 1:loop
        
        D = ATA*X_HAT - ATy + mu*(X_HAT - W - B);
        DTD = D'*D;
        G = D'*(ATA + mu*IM)*D;
        Step_Matrix = abs(DTD./G); 
       STEP_LENGTH = diag(diag(Step_Matrix));
       X = X_HAT - D*STEP_LENGTH;
       X_HAT = X;         
  end
    
    B = B - (X - W);
   
    X_IMG = col2im(X, [patch_size patch_size],[Row Col], 'distinct');
    
    All_PSNR(j)    =   csnr(X_IMG,X_org,0,0);
    
    
       BRM_Results{j}            =                        X_IMG;
    
    fprintf('IterNum = %d, PSNR = %f, SSIM = %f\n',j,csnr(X_IMG,X_org,0,0),cal_ssim(X_IMG,X_org, 0,0));
    
    if j>2
        
        Err_or      =  norm(abs(BRM_Results{j}) - abs(BRM_Results{j-1}),'fro')/norm(abs(BRM_Results{j-1}), 'fro');
        
        if  All_PSNR(j)-All_PSNR(j-1)<0
            break;
        end
    end
    
end


Reconstructed_image = X_IMG;

PSN_Result  = csnr(Reconstructed_image,X_org,0,0);
FSIM_Result = FeatureSIM(Reconstructed_image,X_org);
SSIM_Result = cal_ssim(Reconstructed_image,X_org,0,0);
end

