 function BehavSession_Down = Behavior_Down_Analysis(subID)
% Extract behavior performance metric of BCI down condition 
% Input:  Subject index  
% Output: PVC behavior performance for one session

% sample data folder 
Datapath = '/home/hjiang/Project_BCIMeditation/Data_Github/SampleData';
% Load the data 
load(fullfile(Datapath,strcat(subID,'BCI_UD')))

%% Loop for each session 

BehavSession_Down=length(BCI_UD.DHitInds)/length(BCI_UD.DInds);


end
 


