 function  Down_ConnAlpha = Source_Connectivity_Analysis(subID)
% compute 9-15 Hz alpha source connectivity
% Input: subID---subject ID
% Output: Down_ConnAlpha [90 90] matrix---alpha source for BCI down condition

% Fieldtrip path 
FTpath   = '/home/hjiang/Toolbox/fieldtrip-20180805/fieldtrip-20180805/'; 
% sample data folder 
Datapath = '/home/hjiang/Project_BCIMeditation/Data_Github/SampleData';
% Load the data 
load(fullfile(Datapath,strcat(subID,'BCI_UD')))

% Alpha source  conn 
Down_ConnAlpha = zeros(90,90);   
    
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
 %%   grid

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

%% create source template structure 
SourceTemplate          = [];
SourceTemplate.freq     = 10;  
SourceTemplate.dim      = grid.dim;
SourceTemplate.inside   = grid.inside;
SourceTemplate.pos      = grid.pos;
SourceTemplate.method   = 'average';   

%% Get grid ROI
atlas = ft_read_atlas(fullfile(templatedir,'atlas/aal/ROI_MNI_V4.nii'));
cfg              = []; 
cfg.interpmethod = 'nearest'; 
cfg.parameter    = 'tissue';
sourcemodelROI   = ft_sourceinterpolate(cfg,atlas,SourceTemplate); 
% get the most central voxel
tissuelabels  = atlas.tissuelabel;
ROIsizes      =  zeros(1,90);
posROI        = zeros(90,1);
ROIinds       = cell(1,90);
Allinds       = [];

for i = 1:90
ROIind      = find(sourcemodelROI.tissue==i);
Allinds      = [Allinds;ROIind];
ROIinds{i}  = ROIind;
ROIsizes(i) = numel(ROIind);
Dists       = zeros(numel(ROIind),1);
pos         = SourceTemplate.pos(ROIind,:);

% get the most central voxel 
for j = 1:size(pos,1)  
 currentPos   =  repmat(pos(j,:),[numel(ROIind) 1]);
 Dist         =  (pos-currentPos).^2;
 Dists(j)     =  sum(Dist(:))/numel(ROIind);
end
[~, ROIid]    = min(Dists);
posROI(i)     = ROIind(ROIid);
end

%  ROI grid
gridROI           = grid;
gridROI.leadfield = grid.leadfield(1,posROI);
gridROI.inside    = grid.inside(posROI,1);
gridROI.pos       = grid.pos(posROI,:);

%% setting parameters 
     lambda     = '5%';
     band       = 'Alpha';
     foi        = 12;
     tapsmofrq  = 3;
     taper      = 'dpss';    % 'dpss'/ 'hanning'
     ConnMeth   = 'powcorr_ortho';     % 'coh'/ 'powcorr_ortho'/ 'powcorr'

% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.taper        = taper;
cfg.output       = 'fourier';
cfg.keeptrials   = 'yes';
cfg.foi          = foi;
cfg.tapsmofrq    = tapsmofrq;
powcsd           = ft_freqanalysis(cfg, BCI_UD_Feed);

% beamform common filter
cfg                    = []; 
cfg.method             = 'pcc';
cfg.elec               = elecs;
cfg.keeptrials         = 'yes';
cfg.channel            = elecs.label(s2);
cfg.frequency          = powcsd.freq;  
cfg.grid               = gridROI; 
cfg.vol                = vol;
% cfg.senstype           = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.pcc.keepfilter     = 'yes';
cfg.pcc.lambda         = lambda;
cfg.pcc.projectnoise   = 'yes';
cfg.pcc.fixedori       = 'yes';
cfg.pcc.normalize      = 'yes';
source                 = ft_sourceanalysis(cfg, powcsd);

%% connectivity 
% connect 
switch ConnMeth
 case 'coh'
% imag
cfg         = [];
cfg.method  = 'coh';
cfg.complex = 'absimag';
source_conn = ft_connectivityanalysis(cfg, source);
conn        = source_conn.cohspctrm;

case 'powcorr_ortho'
% 'powcorr_ortho'
cfg         = [];
cfg.method  ='powcorr_ortho';
source_conn = ft_connectivityanalysis(cfg, source);
conn  = abs(source_conn.powcorrspctrm);
conn(logical(eye(size(conn)))) = 0;

case 'powcorr'
% 'powcorr'
cfg         = [];
cfg.method  ='powcorr';
source_conn = ft_connectivityanalysis(cfg, source);
conn         = source_conn.powcorrspctrm;
% figure;imagesc(conn);
% saveas(gcf,fullfile(outdir,strcat(subID,'Conn',band)),'jpg')
end
Down_ConnAlpha = conn; 

end

