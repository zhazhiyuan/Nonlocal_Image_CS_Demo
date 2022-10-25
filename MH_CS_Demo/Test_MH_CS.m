clc
clear
m_1=0; 
m_2=0;    
m_3=0;  
m_4=0;  
m_5=0; 


m_6=0; 
m_7=0;    
m_8=0;  
m_9=0;  
m_10=0; 


m_11=0; 
m_12=0;    
m_13=0;  
m_14=0;  
m_15=0; 

All_data_Results_1 = cell(1,400);
All_data_Results_2 = cell(1,400);
All_data_Results_3 = cell(1,400);
All_data_Results_4 = cell(1,400);
All_data_Results_5 = cell(1,400);


All_data_Results_6 = cell(1,400);
All_data_Results_7 = cell(1,400);
All_data_Results_8 = cell(1,400);
All_data_Results_9 = cell(1,400);
All_data_Results_10 = cell(1,400);


All_data_Results_11 = cell(1,400);
All_data_Results_12 = cell(1,400);
All_data_Results_13 = cell(1,400);
All_data_Results_14 = cell(1,400);
All_data_Results_15 = cell(1,400);

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
    
miss_rate        =       [0.1,0.2,0.3,0.4,0.5]; % 0.6 represents Inlayed Text Removal

Subrate           =       miss_rate(j)


 if  Subrate==0.1
     

[Ori, Subrate, PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s] =MH_CS_Main(filename,  Subrate); 
 
 m_1= m_1+1;
 
 s=strcat('A',num2str(m_1));
 
 All_data_Results_1{m_1}={Ori, Subrate,  PSNR_Final,   FSIM_Final,   SSIM_Final,  Time_s};
 
 xlswrite('MH_CS_0.1.xls', All_data_Results_1{m_1},'sheet1',s);
 
 
elseif  Subrate==0.2
     
     
[Ori, Subrate, PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s] =MH_CS_Main(filename,  Subrate); 
 
 m_4= m_4+1;
 
 s=strcat('A',num2str(m_4));
 
 All_data_Results_4{m_4}={Ori, Subrate,  PSNR_Final,   FSIM_Final,   SSIM_Final,  Time_s};
 
 xlswrite('MH_CS_0.2.xls', All_data_Results_4{m_4},'sheet1',s);
 
 
 elseif  Subrate==0.3
     
 
     
[Ori, Subrate, PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s] =MH_CS_Main(filename,  Subrate); 
 
 m_7= m_7+1;
 
 s=strcat('A',num2str(m_7));
 
 All_data_Results_7{m_7}={Ori, Subrate,  PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s};
 
 xlswrite('MH_CS_0.3.xls', All_data_Results_7{m_7},'sheet1',s);
 
 
  elseif  Subrate==0.4
     

     
[Ori, Subrate, PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s] =MH_CS_Main( filename,  Subrate); 
 
 m_10=  m_10+1;
 
 s=strcat('A',num2str( m_10));
 
 All_data_Results_10{ m_10}={Ori, Subrate,  PSNR_Final,   FSIM_Final,   SSIM_Final,   Time_s};
 
 xlswrite('MH_CS_0.4.xls', All_data_Results_10{ m_10},'sheet1',s);
 
 
 
 
 else
     

     
[Ori, Subrate, PSNR_Final,  FSIM_Final,  SSIM_Final,  Time_s] =    MH_CS_Main(filename,  Subrate); 
 
 m_13=  m_13+1;
 
 s=strcat('A',num2str( m_13));
 
 All_data_Results_13{ m_13}={Ori, Subrate,  PSNR_Final,   FSIM_Final,   SSIM_Final,   Time_s};
 
 xlswrite('MH_CS_0.5.xls', All_data_Results_13{ m_13},'sheet1',s);
 
 end

clearvars -except filename i m_1 All_data_Results_1 m_2 All_data_Results_2 m_3 All_data_Results_3 m_4 All_data_Results_4 m_5 All_data_Results_5 ...
m_6 All_data_Results_6 m_7 All_data_Results_7 m_8 All_data_Results_8 m_9 All_data_Results_9 m_10 All_data_Results_10 m_11 All_data_Results_11 ...
m_12 All_data_Results_12 m_13 All_data_Results_13 m_14 All_data_Results_14 m_15 All_data_Results_15
 end
clearvars -except filename  m_1 All_data_Results_1 m_2 All_data_Results_2 m_3 All_data_Results_3 m_4 All_data_Results_4 m_5 All_data_Results_5 ...
m_6 All_data_Results_6 m_7 All_data_Results_7 m_8 All_data_Results_8 m_9 All_data_Results_9 m_10 All_data_Results_10 m_11 All_data_Results_11 ...
m_12 All_data_Results_12 m_13 All_data_Results_13 m_14 All_data_Results_14 m_15 All_data_Results_15
end






         