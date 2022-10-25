
function [Reconstructed_image, PSN_Result,FSIM_Result,SSIM_Result] = BCS_ALSB_Recovery_SBI(Y, Phi, Opts)

NumRows = Opts.NumRows;
NumCols = Opts.NumCols;
BlockSize = Opts.BlockSize;
IterNum = Opts.IterNum;
OrgImg = Opts.OrgImg;
ALSB_Thr = Opts.ALSB_Thr;
InitImg = Opts.InitImg;
mu = Opts.mu;
Inloop = Opts.Inloop;

X = im2col(InitImg, [BlockSize BlockSize], 'distinct');

U = zeros(size(X));
B = zeros(size(X));


ATA = Phi'*Phi;
ATy = Phi'*Y;
IM = eye(size(ATA));

All_PSNR = zeros(1,IterNum);

for i = 1:IterNum
    
    X_hat = X;
    
    R = col2im(X_hat-B, [BlockSize BlockSize], [NumRows NumCols], 'distinct');
    
    X_bar = ALSB_Solver(R,ALSB_Thr);    
    X_bar = im2col(X_bar, [BlockSize BlockSize], 'distinct');
    
    U = X_bar;
    
    for ii = 1:Inloop
        D = ATA*X_hat - ATy + mu*(X_hat - U - B);
        DTD = D'*D;
        G = D'*(ATA + mu*IM)*D;
        Step_Matrix = abs(DTD./G); 
        Step_length = diag(diag(Step_Matrix));
        X = X_hat - D*Step_length;
        X_hat = X;  
    end
    
    B = B - (X - U);
    
    
    
    CurImg = col2im(X, [BlockSize BlockSize], [NumRows NumCols], 'distict');
    fprintf('IterNum = %d, PSNR = %f\n',i,csnr(CurImg,OrgImg,0,0));
        All_PSNR(i)    =   csnr(CurImg,OrgImg,0,0);    
    
    if i>1
        if (All_PSNR(i)-All_PSNR(i-1)<0)
            break;
        end
    end
    
    
end

RecImg = col2im(X, [BlockSize BlockSize], [NumRows NumCols], 'distict');

Reconstructed_image = RecImg;

PSN_Result  = csnr(Reconstructed_image,OrgImg,0,0);
FSIM_Result = FeatureSIM(Reconstructed_image,OrgImg);
SSIM_Result = cal_ssim(Reconstructed_image,OrgImg,0,0);
end

