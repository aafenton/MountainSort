clear
cd('~/ss')
addpath(genpath(pwd))

mat_name = 'M9_052214_blackbox-cl.mat';
%mat_name = 'M16_090414_stationary2-cl.mat';
% mat_name = '0615R16BC-cl.mat';
load(['/media/psf/PH/DATA/' mat_name]);

%% preprocessing and write into mda

nchs=4; % 1 tetrode has 4 electrode channels
sl = tetrodeSamplesPerBlock; % sample length, usually 96 (2ms, samplerate:48000)
sp=24; % padding length
Data = reshape(tetrodeData,nchs,sl,[]);

iCh = 1; % can use any of the tetrode in 1:length(Chs)
Chs = unique(tetrodeChannel);
idxs = tetrodeChannel==Chs(iCh); % pick out the data in this tetrode

% U = tetrodeUnit(idxs); unique(U')
% T = tetrodeTimestamp(idxs); min(diff(T)) 
dtac = reshape(Data(:,:,idxs),nchs,[]); % constructing continuous data
dtac = dtac - mean(dtac,2); % subtract mean before padding with zeros
dta = reshape(dtac,nchs,sl,[]); 
dta = cat(2,zeros(nchs,sp,size(dta,3)),dta);
dtac = reshape(dta,nchs,[]); 
dtac = [dtac,zeros(nchs,sp)];
% dtac = [dtac(2:4,:);dtac(1,:)]; % should not affect the result, but?

mda_name = 'ss8.mda'; 
writemda(dtac,mda_name,'float32');

%% generating terminal command and sort

tic
clip_size = 64; clip_shift = 8;
input_clip_size = sp + sl;
det_th = 2.8; % event detection threshold in stdev
det_itv = 30; % event detection blocking period

% For discarding noisy clusters
ndt = sp + 12 + det_itv; % noisy detection time, 12: expected peak time
td_th = 0.5; % allowed ratio of timestamps after ndt
nd_th = 0.1; % noise overlap threshold
oe_th = 0.5; % overlapping events fraction threshold

discard_or_not = 'true';
merge_or_not = 'true';
fit_or_not = merge_or_not;
whitening = 'true';
extract_features = 0; 

firing_name = '/media/psf/PH/firing.mda';
metric_name = '/media/psf/PH/metric.json';

% C = dtac*dtac'/size(dtac,2); [V,D] = eig(C); W = V/sqrt(D)*V'   
% pre-whitening
% dX = [1:24, 72:120];
% dta(:,dX,:)=[];
% dta = reshape(dta,4,[]);
% nn = size(dta,2);
% C = dta*dta'/nn;
% [V,D] = eig(C);
% W = V/sqrt(D)*V';
% dtac = W*dtac;

command_sort = ['mlp-run'...
    ' ~/mountainlab/mountainsort3.mlp sort'...
    ' --clip_shift=' num2str(clip_shift)...
    ' --clip_size=' num2str(clip_size)...
    ' --clip_padding=' num2str(sp)...
    ' --detect_interval=' num2str(det_itv)...
    ' --detect_threshold=' num2str(det_th)...
    ' --noise_detect_time=' num2str(ndt)...
    ' --detect_time_discard_thresh=' num2str(td_th)...
    ' --noise_overlap_discard_thresh=' num2str(nd_th)...
    ' --input_clip_size=' num2str(input_clip_size)...
    ' --event_fraction_threshold=' num2str(oe_th)...
    ' --consolidation_factor=0.95'...
    ' --label_map_out=/media/psf/PH/lmap.mda'... 
    ' --whiten=' whitening...
    ' --discard_noisy_clusters=' discard_or_not...
    ' --merge_across_channels=' merge_or_not...
    ' --fit_stage=' fit_or_not...
    ' --filt=' mda_name... 
    ' --pre_out=pre.mda'...
    ' --cluster_metrics_out=' metric_name...
    ' --firings_out=' firing_name];

if (extract_features==0)

    system(command_sort);

else
    
command_sort = [command_sort ' --extract_fets=true --features_out=fets.mda'];
system(command_sort);

lmap = readmda('/media/psf/PH/lmap.mda');
fets = readmda('fets.mda');
F = readmda(firing_name);
keepCluster = zeros(1,size(F,2));
for i = 1:size(lmap,1)
    keepCluster(F(3,:)==lmap(i,2)) = lmap(i,1);
end
Nkeep = sum(unique(keepCluster)>0);

[nj,ni] = size(fets);
fid = fopen('fets.txt','w');
fprintf(fid,'Cluster f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 \n');
for i = 1:ni
    fprintf(fid,'%d\t',keepCluster(i));
    for j = 1:nj
        fprintf(fid,'%f\t',fets(j,i));
    end
    fprintf(fid,'\n');
end
fclose(fid);

system('isoi fets.txt /media/psf/PH/Is/IsoI.txt');

end


command_view = ['mountainview'...
    ' --raw=/home/parallels/ss/pre.mda'...
    ' --samplerate=48000'... 
    ' --cluster_metrics=' metric_name...
    ' --firings=' firing_name];
clipboard('copy',command_view)

toc
