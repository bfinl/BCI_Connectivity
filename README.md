# BCI_Connectivity

This readme document describes software codes which have been developed under support from the National Institutes of Health via grants NIH AT009263, EB008389, EB029354, MH114233, and NS096761. The source codes are provided as a service to the scientific community and may be used for any non-commercial purposes. Users should use the codes or data at their own risks with no guarantees provided, as is. If anyone should use the codes provided here in its entirety or partially, we ask them to cite the following publication in any of their publications or presentations:

" Jiang H, Stieger J, Engel S, Cline C, M Kreitzer, He B (In press). Modulations of frontolimbic alpha activity tracks intentional rest BCI control improvement through mindfulness meditation. Sci Rep. "


This program is a free software for academic research: you can redistribute it and/or modify it for non-commercial uses, under the license terms provided in LICENSE.MD in this GitHub repository. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the License for more details. This program is for research purposes only. This program CAN NOT be used for commercial purposes. This program SHOULD NOT be used for medical purposes. The authors WILL NOT be responsible for using the program in medical conditions.

 This folder contains the codes and one sample data in the manuscript.In order to run the code, you need to install the fiedltrip toolbox (https://www.fieldtriptoolbox.org/). The file called “Demo_Example.m” summarizes the pipeline for generating an example. This file calls 4 other main scripts as follows:

  --- Behavior_Down_Analysis.m (Calculate behavior in the down BCI conditon)  
  --- Sensor_Spectral_Analysis.m (Calculate Spectral power at the sensor level);
  --- Source_Power_Analysis.m (Calculate 9-15 Hz alpha activity source with DICS); 
  --- Source_Connectivity_Analysis.m (Calculate 9-15 Hz alpha source connectivity with power orthoganaion correation); 
