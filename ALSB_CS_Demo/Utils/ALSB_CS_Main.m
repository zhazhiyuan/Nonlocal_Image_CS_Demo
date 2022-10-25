function [filename, Subrate, PSN_Result,FSIM_Result,SSIM_Final,Time_s] =ALSB_CS_Main(filename,IterNum,Subrate)



        time0         =   clock;
        Original_Filename = [filename '.tif'];
        Original_Image = imread(Original_Filename);
        [NumRows, NumCols,kkk] = size(Original_Image);
        
        if kkk==3
            OrgImg=double(rgb2gray(Original_Image));
        else
           OrgImg=double((Original_Image));
        end
        

        BlockSize = 32;
        

        clear Opts
        Opts = [];
        
        if ~isfield(Opts,'OrgName')
            Opts.OrgName = filename;
        end
        
        if ~isfield(Opts,'OrgImg')
            Opts.OrgImg = OrgImg;
        end
        
        if ~isfield(Opts,'NumRows')
            Opts.NumRows = NumRows;
        end
        
        if ~isfield(Opts,'NumCols')
            Opts.NumCols = NumCols;
        end
        
        if ~isfield(Opts,'BlockSize')
            Opts.BlockSize = BlockSize;
        end
        
        if ~isfield(Opts,'Subrate')
            Opts.Subrate = Subrate;
        end
        
        if ~isfield(Opts,'IterNum')
            Opts.IterNum = IterNum;
        end
        
        if ~isfield(Opts,'ALSB_Thr')
            Opts.ALSB_Thr = 8;
        end
        
        if ~isfield(Opts,'PlogFlag')
            Opts.mu = 0.0025;
        end
        
        if ~isfield(Opts,'Inloop')
            Opts.Inloop = 200;
        end
        
        if ~isfield(Opts,'PlogFlag')
            Opts.PlogFlag = 1;
        end
        %% Parameter Set -- End %%
        
        %% CS Sampling -- Begin %%
        N = BlockSize^2;
        M = round(Subrate * N);
        
        % randn('seed',0);
        PhiTemp = orth(randn(N, N))';
        Phi = PhiTemp(1:M, :);
        
        X = im2col(OrgImg, [BlockSize BlockSize], 'distinct');
        
        Y = Phi * X;
        %% CS Sampling -- End %%
        
        %% Initialization -- Begin %%
        [X_MH X_DDWT] = MH_BCS_SPL_Recovery(Y, Phi, Opts);
        
        
        if ~isfield(Opts,'InitImg')
            Opts.InitImg = X_MH;
        end
        %% Initialization -- End %%
        
        fprintf('%s,rate=%0.2f\n Initial PSNR=%0.2f\n',filename,Subrate,csnr(Opts.InitImg ,OrgImg,0,0));
        %% CS Recovery by ALSB -- Begin %%
        tic;
        
       [reconstructed_image, PSN_Result,FSIM_Result,SSIM_Final] = BCS_ALSB_Recovery_SBI(Y, Phi, Opts);
        
         Time_s =(etime(clock,time0));  
        if Subrate==23.977
        Final_Name= strcat(filename,'_ALSB_CS_',num2str(Subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.1_Results/',Final_Name));

        
        elseif Subrate==0.2
            
        Final_Name= strcat(filename,'_ALSB_CS_',num2str(Subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.2_Results/',Final_Name));

        
        elseif Subrate==0.3
            
        Final_Name= strcat(filename,'_ALSB_CS_',num2str(Subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.3_Results/',Final_Name));

        else
            
        Final_Name= strcat(filename,'_ALSB_CS_',num2str(Subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.4_Results/',Final_Name));
                      
       end          
        
end