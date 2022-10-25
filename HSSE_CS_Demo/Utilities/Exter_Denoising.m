
function  [Exter_Out]       =       Exter_Denoising  (Exte,  Opts,  model)

randn ('seed',0);

im_out                       =               Exte.nim;

Exte.nSig0                   =               Exte.nSig;

[h,  w]                      =               size(im_out);

Exte.maxr                    =               h-Exte.ps+1;

Exte.maxc                    =               w-Exte.ps+1;

Exte.maxrc                   =               Exte.maxr * Exte.maxc;

Exte.h                       =                h;

Exte.w                       =                w;

r                            =                1:Exte.step:Exte.maxr;

Exte.r                       =                [r r(end)+1:Exte.maxr];

c                            =                1:Exte.step:Exte.maxc;

Exte.c                       =                [c c(end)+1:Exte.maxc];

Exte.lenr                    =                length(Exte.r);

Exte.lenc                    =                length(Exte.c);

Exte.lenrc                   =                Exte.lenr*Exte.lenc;

Exte.ps2                     =                Exte.ps^2;

for     ite   =    1
    
    %  im_out = im_out + Exte.delta*(Exte.nim - im_out);
    
  %  if ite == 1
  %      Exte.nSig = Exte.nSig0;
  %  else
  %      dif = mean( mean( (Exte.nim - im_out).^2 ) ) ;
  %      Exte.nSig = sqrt( abs( Exte.nSig0^2 - dif ) )*Exte.eta;
  %  end
    % search non-local patch groups
    [nDCnlX,blk_arr,DC,Exte]              =            CalNonLocal( im_out, Exte);
    % Gaussian dictionary selection by MAP
    if     mod(ite-1,2)     ==      0
        
        PYZ                  =               zeros(model.nmodels,size(DC,2));
        
        sigma2I              =               Exte.nSig^2*eye(Exte.ps2);
        
        for    i      =       1:model.nmodels
            
            sigma     =       model.covs(:,:,i) + sigma2I;
            
            [R,~]     =       chol(sigma);
            
            Q         =        R'\nDCnlX;
            
            TempPYZ   =       - sum(log(diag(R))) - dot(Q,Q,1)/2;
            
            TempPYZ   =        reshape(TempPYZ,[Exte.nlsp size(DC,2)]);
            
            PYZ(i,:)  =        sum(TempPYZ);
            
        end
        % find the most likely component for each patch group
        [~,dicidx]    =        max(PYZ);
        
        dicidx        =        dicidx';
        
        [idx,  s_idx] =        sort(dicidx);
        
        idx2          =         idx(1:end-1) - idx(2:end);
        
        seq           =         find(idx2);
        
        seg           =         [0; seq; length(dicidx)];
        
    end
    % Weighted Sparse Coding
    
    
    X_hat             =         zeros(Exte.ps2,Exte.maxrc);
    
    W                 =         zeros(Exte.ps2,Exte.maxrc );
    
    for   j           =         1:length(seg)-1
        
        idx           =         s_idx(seg(j)+1:seg(j+1));
        
        cls           =         dicidx(idx(1));
        
        D             =         Exte.D(:,:, cls);
        
        S             =         Exte.S(:,cls);
        
        lambdaM       =         repmat(2*sqrt(2)*Opts.c2*Exte.nSig^2./ (sqrt(S)+eps ),[1 Exte.nlsp]);
        
        for i         =          1:size(idx,1)
            
            Y         =          nDCnlX(:,(idx(i)-1)*Exte.nlsp+1:idx(i)*Exte.nlsp);
            
            b         =          D'*Y;
            % soft threshold
            alpha     =          sign(b).*max(abs(b)-(lambdaM/Opts.beta),0);
    %        alpha     =          sign(b).*max(abs(b)-(lambdaM* Opts.mu1),0);
            % add DC components and aggregation
            X_hat(:,blk_arr(:,idx(i)))         =        X_hat(:,blk_arr(:,idx(i)))+bsxfun(@plus,D*alpha, DC(:,idx(i)));
            
            W(:,blk_arr(:,idx(i)))             =        W(:,blk_arr(:,idx(i)))+ones(Exte.ps2,Exte.nlsp);
            
        end
        
    end
    % Reconstruction
    im_out              =                  zeros(h,w);
    
    im_wei              =                  zeros(h,w);
    
    r                   =                  1:Exte.maxr;
    
    c                   =                  1:Exte.maxc;
    
    k                   =                  0;
    
    for i               =              1:Exte.ps
        
        for j           =      1:Exte.ps
            
            k           =       k+1;
            
            im_out(r-1+i,c-1+j)     =       im_out(r-1+i,c-1+j) + reshape( X_hat(k,:)', [Exte.maxr Exte.maxc]);
            
            im_wei(r-1+i,c-1+j)     =       im_wei(r-1+i,c-1+j) + reshape( W(k,:)', [Exte.maxr Exte.maxc]);
        end
    end
    im_out  =  im_out./(im_wei +eps);
    % calculate the PSNR and SSIM
  %  PSNR =   csnr( im_out*255, Opts.I, 0, 0 );
 %   SSIM      =  cal_ssim( im_out*255, Opts.I, 0, 0 );
  %  fprintf('Iter %d : PSNR = %2.4f, SSIM = %2.4f\n',ite, PSNR,SSIM);
end
Exter_Out    =  double (im_out* 255);
end
