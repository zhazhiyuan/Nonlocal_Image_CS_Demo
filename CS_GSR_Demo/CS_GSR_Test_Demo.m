clc
clear
m_20=0; 
m_30=0;    
m_40=0;  
m_10=0;  
m_50=0;  

All_data_Results_50 = cell(1,200);
All_data_Results_20 = cell(1,200);
All_data_Results_30 = cell(1,200);
All_data_Results_40 = cell(1,200);
All_data_Results_10 = cell(1,200);

for i = 1:11
    
ImgNo =i;

switch ImgNo
    
         case 1
                filename = 'barbara';
            case 2
                filename = 'boats';
            case 3
                filename = 'cameraman';
            case 4
                filename = 'fingerprint';    
            case 5
                filename = 'flinstones'; 
                
            case 6
                filename = 'foreman';
            case 7
                filename = 'house';
            case 8
                filename = 'lena256';
            case 9
                filename = 'Monarch';    
            case 10
                filename = 'Parrots'; 
                
            case 11
                filename = 'peppers256';
            
                          
end


for m  =   1:5
    
    filename

rate     =    [0.1,0.2,0.3,0.4,0.5];

Subrate =  rate(m)


%IterNum   =   600;

if  Subrate==0.1
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =GSR_CS_Main(filename,Subrate);
 m_10= m_10+1;
 s=strcat('A',num2str(m_10));
 All_data_Results_10{m_10}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('GSR_CS_0.1_Set_11.xls', All_data_Results_10{m_10},'sheet1',s);
elseif  Subrate==0.2
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =GSR_CS_Main(filename,Subrate);
 m_20= m_20+1;
 s=strcat('A',num2str(m_20));
 All_data_Results_20{m_20}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('GSR_CS_0.2_Set_11.xls', All_data_Results_20{m_20},'sheet1',s);
 elseif  Subrate==0.3
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =GSR_CS_Main(filename,Subrate);
 m_30= m_30+1;
 s=strcat('A',num2str(m_30));
 All_data_Results_30{m_30}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('GSR_CS_0.3_Set_11.xls', All_data_Results_30{m_30},'sheet1',s);
elseif  Subrate==0.4
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =GSR_CS_Main(filename,Subrate);
 m_40= m_40+1;
 s=strcat('A',num2str(m_40));
 All_data_Results_40{m_40}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('GSR_CS_0.4_Set_11.xls', All_data_Results_40{m_40},'sheet1',s);
else
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s] =GSR_CS_Main(filename,Subrate);
 m_50= m_50+1;
 s=strcat('A',num2str(m_50));
 All_data_Results_50{m_50}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 xlswrite('GSR_CS_0.5_Set_11.xls', All_data_Results_50{m_50},'sheet1',s);    
    
end


clearvars -except filename i m_20 All_data_Results_20 m_30 All_data_Results_30 m_40 All_data_Results_40 m_10 All_data_Results_10 m_50 All_data_Results_50
end
clearvars -except filename  m_20 All_data_Results_20 m_30 All_data_Results_30 m_40 All_data_Results_40 m_10 All_data_Results_10 m_50 All_data_Results_50
end





         