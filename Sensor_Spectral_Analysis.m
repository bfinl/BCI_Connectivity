function FeedPows = Sensor_Spectral_Analysis(subID)
% Compute the 1-30 Hz power spectrum of 1 s befroe the feedback 
% Input:  subID---subject ID
% Output: FeedPows---Power spectrum for the  BCI down
% conditions

% sample data folder 
Datapath = '/home/hjiang/Project_BCIMeditation/Data_Github/SampleData';
% Load the data 
load(fullfile(Datapath,strcat(subID,'BCI_UD')))
      
%% get data  before the hitting the target 
    Fs  = BCI_UD.fsample;
    TaskData  = cell(1,length(BCI_UD.trial));
    TimeSeri  = cell(1,length(BCI_UD.trial));
    for i = 1:length(BCI_UD.trial)
     TaskData{i}   = BCI_UD.trial{1,i}(:,floor((BCI_UD.trialinfo(i).t_result+1)*Fs):floor((BCI_UD.trialinfo(i).t_result+2)*Fs));
     TimeInd  =  0:1/Fs:(size(TaskData{i},2)-1)/Fs;
     TimeSeri{i}   = TimeInd; 
    end    
     
    BCI_UD_Feed       =  BCI_UD;
    BCI_UD_Feed.trial = TaskData;
    BCI_UD_Feed.time  = TimeSeri;
    
    BCI_UD_Feed.label = cellfun(@(x) upper(x), BCI_UD_Feed.label,'uniformoutput',0);
    BCI_UD_Feed.elec.label = cellfun(@(x) upper(x), BCI_UD_Feed.elec.label,'uniformoutput',0);
    
   %%%%%%%%% select only down condition trials %%%%%%%%%%
    cfg              = []; 
    cfg.trials       = BCI_UD.DInds;  % only select down trial  DInds/DHitInds      
    BCI_UD_Feed      = ft_selectdata(cfg,BCI_UD_Feed);
  

%%%%%%%%%% Frequency analysis %%%%%%%%%%%%%%%%% 
cfg = [];
cfg.output       = 'pow';
cfg.method       = 'mtmfft';
cfg.taper        = 'dpss';     % 'hanning'/'dpss'
cfg.tapsmofrq    = 2;             
cfg.keeptrials   = 'no';
cfg.foilim       = [1 30];
Feed_pow         = ft_freqanalysis(cfg, BCI_UD_Feed);
FeedPows         = Feed_pow ;



end