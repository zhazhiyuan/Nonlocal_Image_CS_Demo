clc
clear
m_20=0; 
m_30=0;    
m_40=0;  
m_10=0;  
m_50=0; 
m_60=0; 

All_data_Results_2_20 = cell(1,200);
All_data_Results_2_30 = cell(1,200);
All_data_Results_2_40 = cell(1,200);
All_data_Results_2_10 = cell(1,200);
All_data_Results_2_50 = cell(1,200);
All_data_Results_2_60 = cell(1,200);


%run '.\matconvnet-1.0-beta23\matlab\vl_setupnn.m'

for i =24
ImageNum =i;

switch ImageNum
    
            case 1
                filename = 'airplane256';
            case 2
                filename = 'Bahoon_256';
            case 3
                filename = 'Barbara256';
            case 4
                filename = 'boats_256';    
            case 5
                filename = 'bridge256'; 
                
            case 6
                filename = 'cameraman';
            case 7
                filename = 'couple256';
            case 8
                filename = 'couple_256';
            case 9
                filename = 'elaine256';    
            case 10
                filename = 'Fence_256'; 
                
            case 11
                filename = 'fingerprint256';
            case 12
                filename = 'flower_256';
            case 13
                filename = 'foreman256';     
                
            case 14
                filename = 'girl256';
            case 15
                filename = 'Goldhill256';
            case 16
                filename = 'House256';
            case 17
                filename = 'J.Bean_256';    
            case 18
                filename = 'Lake256'; 
                
            case 19
                filename = 'Leaves256';
            case 20
                filename = 'lena256';
            case 21
                filename = 'lin_256';     
                
            case 22
                filename = 'man256';
            case 23
                filename = 'Miss_256';
            case 24
                filename = 'Monarch256';
            case 25
                filename = 'Parrots256';    
            case 26
                filename = 'Parthenon'; 
                
            case 27
                filename = 'pentagon_256';
            case 28
                filename = 'peppers256';
            case 29
                filename = 'plants_256';    
            case 30
                filename = 'starfish256';       
             case 31
                filename = 'straw_256';                
            
end
for j  =   1:5
    


filename

ratio_Num        =       [0.1, 0.2, 0.3, 0.4, 0.5]; 


Subrate =  ratio_Num(j);


if  j ==1


 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s]= CSNet_CS_Main(filename,Subrate);
 
 m_10= m_10+1;
 
 s=strcat('A',num2str(m_10));
 
 All_data_Results_2_10{m_10}={Ori, Subrate,  PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 
xlswrite('CSNet_ratio_0.1.xls', All_data_Results_2_10{m_10},'sheet1',s);
 

 
 
 
 
 elseif  j == 2
     
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s]= CSNet_CS_Main(filename,Subrate);
 
 m_20= m_20+1;
 
 s=strcat('A',num2str(m_20));
 
 All_data_Results_2_20{m_20}={Ori, Subrate,  PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 
 xlswrite('CSNet_ratio_0.2.xls', All_data_Results_2_20{m_20},'sheet1',s);

 
  elseif  j == 3
      
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s]= CSNet_CS_Main(filename,Subrate);
 
 m_30= m_30+1;
 
 s=strcat('A',num2str(m_30));
 
 All_data_Results_2_30{m_30}={Ori, Subrate,  PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 
 xlswrite('CSNet_ratio_0.3.xls', All_data_Results_2_30{m_30},'sheet1',s);

 
 
  elseif  j == 4
    
 [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s]= CSNet_CS_Main(filename,Subrate);
 
 m_40= m_40+1;
 
 s=strcat('A',num2str(m_40));
 
 All_data_Results_2_40{m_40}={Ori, Subrate,  PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 
 xlswrite('CSNet_ratio_0.4.xls', All_data_Results_2_40{m_40},'sheet1',s);
 
else
    
     [Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s]= CSNet_CS_Main(filename,Subrate);
 
 m_50= m_50+1;
 
 s=strcat('A',num2str(m_50));
 
 All_data_Results_2_50{m_50}={Ori, Subrate,  PSNR_Final,FSIM_Final,SSIM_Final,Time_s};
 
 xlswrite('CSNet_ratio_0.5.xls', All_data_Results_2_50{m_50},'sheet1',s);
 

 
 
 
 end


clearvars -except filename i m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40 m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60
end
clearvars -except filename m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40 m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60
end






         