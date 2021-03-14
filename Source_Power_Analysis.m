function  Source_Alpha =Source_Power_Analysis(subID)
% compute 9-15 Hz alpha source with DICS
% Input: subID---subject ID
% Output: Source_Alpha---alpha source for BCI down condition

% Fieldtrip path 
FTpath   = '/home/hjiang/Toolbox/fieldtrip-20180805/fieldtrip-20180805/'; 
% sample data folder 
Datapath = '/home/hjiang/Project_BCIMeditation/Data_Github/SampleData';
% Load the data 
load(fullfile(Datapath,strcat(subID,'BCI_UD')))


% Alpha source 
Source_Alpha = zeros(7452,1);   
       
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
    
      %%%%%%%%% select only down trials %%%%%%%%%%
       cfg              = []; 
       cfg.trials       = BCI_UD.DInds;  % only select down trial       
       BCI_UD_Feed      = ft_selectdata(cfg,BCI_UD_Feed); 
 %%  template  grid

templatedir = fullfile(FTpath,'template')  ;
% standard bem model
% http://www.fieldtriptoolbox.org/template/headmodel/
load(fullfile(templatedir,'headmodel/standard_bem'))

% template atlas 
% atlas = ft_read_atlas(fullfile(templatedir,'atlas/aal/ROI_MNI_V4.nii'));
% get elec info;
elecs_EEG  = BCI_UD_Feed.elec;  
% elecs.label = cellfun(@(x) upper(x),elecs.label,'uniformoutput',0);

elecs      = ft_read_sens(fullfile(templatedir,'electrode/standard_1020.elc'));
elecs.label = cellfun(@(x) upper(x),elecs.label,'uniformoutput',0);

[s1,s2]=match_str(elecs_EEG.label,elecs.label); 


% common grid/filter
cfg                 = [];
cfg.elec            = elecs; 
cfg.vol             = vol;
cfg.reducerank      = 3;         % default is 3 for EEG, 2 for MEG
cfg.grid.resolution = 0.8;       % use a 3-D grid with a  cm resolution
cfg.grid.unit       = 'cm';
cfg.grid.tight      = 'yes';
% cfg.normalize       = 'yes';
cfg.channel         = elecs.label(s2);
[grid]              = ft_prepare_leadfield(cfg);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  9-15 Hz Alpha source %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lambda     = '10%';
band       = 'Alpha';
foi        = 12;
tapsmofrq  = 3;
taper      = 'dpss';  % 'dpss'/ 'hanning'

%%%%%%%%%   Feedback  %%%%%%%%%%%%%%%%%%     
% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.taper        = taper;
cfg.channel      = elecs.label(s2);
cfg.output       = 'powandcsd';
cfg.keeptrials   = 'yes';
cfg.foi          = foi;
cfg.tapsmofrq    = tapsmofrq;
Feed_powcsd     = ft_freqanalysis(cfg, BCI_UD_Feed);

% beamform common filter
cfg                   = []; 
cfg.method            = 'dics';
cfg.elec              = elecs; 
cfg.channel           = Feed_powcsd.label;
cfg.frequency         = Feed_powcsd.freq;
% cfg.keeptrials        = 'yes';
% cfg.rawtrial          = 'yes';
cfg.grid               = grid; 
cfg.vol                = vol;
cfg.senstype           = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter    = 'yes';
cfg.dics.lambda        = lambda;
cfg.dics.projectnoise  = 'yes';
cfg.dics.fixedori      = 'yes';
Feed_source            = ft_sourceanalysis(cfg, Feed_powcsd);

Alpha                 = Feed_source.avg.pow;
Source_Alpha          = Alpha;
 

end