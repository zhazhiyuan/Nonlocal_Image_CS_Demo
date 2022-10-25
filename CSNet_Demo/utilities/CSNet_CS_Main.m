function [filename,subrate,PSN_Result,FSIM_Result, SSIM_Result,Time_s]=  CSNet_CS_Main   (filename,subrate)

        time0   = clock;
        
        Original_Filename = [filename '.tif'];
        Original = imread(Original_Filename);
        
        [~, ~,kkk] = size(Original);
        
        if kkk==3
            image  = (rgb2gray(Original));
        else 
            image  = (Original);
        end
        
    
    samplingRate = subrate;    
    
    
    load(['.\model\sampling' num2str(samplingRate) '.mat']);
        
        
            label = im2single(image);
            input =label;
        
          res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test');
    output = res(end).x;      
        
        
        reconstructed_image  = double(output*255);
      
        
          Time_s =(etime(clock,time0));  
          
          
          PSN_Result  = csnr(reconstructed_image, double(image),0,0);
          FSIM_Result  = FeatureSIM(reconstructed_image, double(image));
          
          SSIM_Result  = cal_ssim(reconstructed_image, double(image),0,0);
          
          
        
        if subrate==0.1

        Final_Name= strcat(filename,'_CSNet_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.1_Results/',Final_Name));
        
        elseif subrate==0.2
            
        Final_Name= strcat(filename,'_CSNet_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.2_Results/',Final_Name));
        
        elseif subrate==0.3
            
        Final_Name= strcat(filename,'_CSNet_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.3_Results/',Final_Name));
        
         elseif subrate==0.4
            
        Final_Name= strcat(filename,'_CSNet_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.4_Results/',Final_Name));
        
        else
           Final_Name= strcat(filename,'_CSNet_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.5_Results/',Final_Name));         
                                
       end    



end

