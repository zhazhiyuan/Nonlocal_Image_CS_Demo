function [filename,  subrate,  PSN_Result,  FSIM_Result,  SSIM_Result,  Time_s] = MH_CS_Main(filename, subrate)


        time0                                   =                                      clock;
        
        block_size                              =                                      32;
        
        original_filename                       =                                      [filename '.tif'];
        
        original_filename                       =                                      imread(original_filename);
        
        [row, col,kk]                           =                                      size(original_filename);
                
        if kk==3
            
        original_image                          =                                     double(rgb2gray((original_filename)));
        
        else
        original_image                          =                                     double((original_filename));
        
        end
       
        randn('seed',0);     
        % Constructe Measurement Matrix (Gaussian Random)
        N                                       =                                      block_size * block_size;
        
        M                                       =                                      round(subrate * N);
        
        Phi                                     =                                      orth(randn(N, N))';
        
        Phi                                     =                                      Phi(1:M, :);
        
        x                                       =                                      im2col(original_image, [block_size block_size], 'distinct');
        
        % Get Measurements
        y                                       =                                      Phi * x;
        
        % Obtain Initilization by MH
        disp('Initilization ...');
        
        [x_MH,  ~]                              =                                      MH_BCS_SPL_Decoder(y, Phi, subrate, row, col);
                
        x_org                                   =                                      original_image;
        
      
        Time_s =(etime(clock,time0));  
        
        PSN_Result                               =                   csnr(x_MH,x_org,0,0);

        FSIM_Result                              =                   FeatureSIM(x_MH,x_org);

       SSIM_Result                              =                   cal_ssim(x_MH,x_org,0,0);       
        
        
        if subrate==0.1

        Final_Name= strcat(filename,'_MH_CS_',num2str(subrate), '_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');

        imwrite(uint8(x_MH),strcat('./MH_CS_0.1_Results/',Final_Name));

        
        elseif subrate==0.2
            
        Final_Name= strcat(filename,'_MH_CS_',num2str(subrate), '_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');

        imwrite(uint8(x_MH),strcat('./MH_CS_0.2_Results/',Final_Name));
        
        
        
        elseif subrate==0.3
            
        Final_Name= strcat(filename,'_MH_CS_',num2str(subrate), '_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');

        imwrite(uint8(x_MH),strcat('./MH_CS_0.3_Results/',Final_Name));
        
        
        
        elseif subrate==0.4
            
        Final_Name= strcat(filename,'_MH_CS_',num2str(subrate), '_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');

        imwrite(uint8(x_MH),strcat('./MH_CS_0.4_Results/',Final_Name));
        
        else
            
        Final_Name= strcat(filename,'_MH_CS_',num2str(subrate), '_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');

        imwrite(uint8(x_MH),strcat('./MH_CS_0.5_Results/',Final_Name));
        
       end    
        
        
        
        
end