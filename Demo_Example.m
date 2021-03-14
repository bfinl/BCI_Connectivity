%%  This is a demo for a single subject analysis of manuscript:
% Jiang H, Stieger J, Engel S, Cline C, M Kreitzer, He B (In press). 
% Modulations of frontolimbic alpha activity tracks intentional rest BCI control
% improvement through mindfulness meditation. Sci Rep. 

%% Calculate behavior in the down BCI conditon
% input is subID
BehavSession_Down = Behavior_Down_Analysis(subID);

%% Calculate Spectral power at the sensor level   
  
FeedPows = Sensor_Spectral_Analysis(subID);
 
 
%% Calculate 9-15 alpha activity source with DICS 

 Source_Alpha = Source_Power_Analysis(subID);
 
 
%% Calculate 9-15 Hz alpha source connectivity with power orthoganaion correation
 
Down_ConnAlpha = Source_Connectivity_Analysis(subID);
 