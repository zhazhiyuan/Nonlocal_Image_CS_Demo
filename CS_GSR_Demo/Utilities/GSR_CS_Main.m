function  [filename, subrate, PSN_Result,FSIM_Result,SSIM_Result,Time_s] =GSR_CS_Main(filename,subrate)


         time0         =   clock;
        Original_Filename = [filename '.tif'];
        Original_Image = imread(Original_Filename);
        [NumRows, NumCols,kkk] = size(Original_Image);
        

        
        Original_Image  = imresize (Original_Image, [NumRows, NumCols]);
        
        
        if kkk==3
            original_image=double(rgb2gray(Original_Image));
        else
           original_image=double((Original_Image));
        end
        
block_size = 32; % Block size   




   [row, col] = size(original_image);
        
        % Constructe Measurement Matrix (Gaussian Random)
        N = block_size * block_size;
        M = round(subrate * N);
        randn('seed',0);
        Phi = orth(randn(N, N))';
        Phi = Phi(1:M, :);
        
        x = im2col(original_image, [block_size block_size], 'distinct');
        
        % Get Measurements
        y = Phi * x;
        
        % Obtain Initilization by MH
        disp('Initilization ...');
        [x_MH x_DWT] = MH_BCS_SPL_Decoder(y, Phi, subrate, row, col);
                
        x_org = original_image;
        
        Opts = [];
        Opts.Phi = Phi;
        Opts.block_size = block_size;
        Opts.row = row;
        Opts.col = col;
        
        if ~isfield(Opts,'initial')
            Opts.initial = double(x_MH);
        end
        
        Opts.org = original_image;
        
        if ~isfield(Opts,'IterNum')
            Opts.IterNum = 120;
        end
                
        if ~isfield(Opts,'mu')
            Opts.mu = 2.5e-3;
        end
        
        if ~isfield(Opts,'lambda')
            Opts.lambda = 0.082;
        end
        
        if ~isfield(Opts,'Inloop')
            Opts.Inloop = 200;
        end
        
        fprintf('Initial PSNR = %0.2f\n',csnr(Opts.org,Opts.initial,0,0));
        
        disp('Beginning of CS-GSR Algorithm for Image Reconstruction....');

        [reconstructed_image All_PSNR]= BCS_GSR_Decoder_SBI_Iter(y, Opts);


RecImg = reconstructed_image;


PSN_Result   =csnr(RecImg,original_image,0,0);

FSIM_Result  = FeatureSIM(RecImg,original_image);

SSIM_Result  =cal_ssim(RecImg,original_image,0,0);



   Time_s =(etime(clock,time0));  
        if subrate==0.1
        Final_Name= strcat(filename,'_GSR_CS_Set_11_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(RecImg),strcat('./ratio_0.1_Results/',Final_Name));

        
        elseif subrate==0.2
            
        Final_Name= strcat(filename,'_GSR_CS_Set_11_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
        
        
        imwrite(uint8(RecImg),strcat('./ratio_0.2_Results/',Final_Name));

        
        elseif subrate==0.3
            
        Final_Name= strcat(filename,'_GSR_CS_Set_11_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
        
        
        imwrite(uint8(RecImg),strcat('./ratio_0.3_Results/',Final_Name));

        elseif subrate==0.4
            
        Final_Name= strcat(filename,'_GSR_CS_Set_11_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
        
        
        imwrite(uint8(RecImg),strcat('./ratio_0.4_Results/',Final_Name));
        
        else
        Final_Name= strcat(filename,'_GSR_CS_Set_11_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
        
        imwrite(uint8(RecImg),strcat('./ratio_0.5_Results/',Final_Name));            
                      
        end          
       
        
end

