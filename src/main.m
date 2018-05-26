%% Read Data

close all
clc

in_filename='../data/new-thyroid.data';
%sD = som_read_data(in_filename);
sD = som_read_data(in_filename);
conf=struct();

%conf.mode='auto';
% BEST SO FAR

%conf.mode='auto';
conf.mode='manual';

conf.msize=[12 6];
conf.lattice='hexa';
conf.radius=[1 1];
conf.trainlen=100;
conf.alpha_ini=0.5;
conf.rough.alpha_ini=0.5;
conf.finet.alpha_ini=0.05;
conf.rough.trainlen=2;
conf.finet.trainlen=6;
conf.shape='sheet';
% SEARCH BEGINS
conf.lattice='hexa';
%conf.lattice='rect';

conf.dlen=size(sD.data,1);
conf.algorithm='batch';

conf.plot=0;
%%

sD = som_normalize(sD,'range');
if isequal(conf.mode,'auto')
    sM = som_make(sD);  %Batch training method
else
    %sM = som_randinit(sD,'msize',conf.msize);
    sM = som_lininit(sD,'msize',conf.msize,'lattice',conf.lattice,'shape',conf.shape);
    
    %conf.algorithm='batch';
    %sTrain = som_train_struct(sM,'dlen',conf.dlen,'algorithm',conf.algorithm,'phase','rough');
    %sTrain.alpha_ini=conf.alpha_ini;
    %sM.topol.lattice='rect';
    %sM.
    %sM = som_batchtrain(sM,sD,'radius',conf.radius, ...
    
    % ROUGH TRAINING PHASE 
    sM = som_seqtrain(sM,sD,'radius',conf.radius, ...
        'msize',conf.msize,'trainlen',conf.rough.trainlen,...
        'trainlen_type','epochs',...
        'lattice',conf.lattice, ...
        'shape',conf.shape, ...
        'alpha_ini', conf.rough.alpha_ini, ...
        'tracking',0);
    [e1,e2,e3]=som_quality(sM,sD);
    fprintf('Final quantization error: %5.3f\n',e1)
    fprintf('Final topographic error:  %5.3f\n',e2)
    fprintf('Final combined error:  %5.3f\n',e3)  

    %sM = som_batchtrain(sM,sD,'radius',conf.radius, ...
    % FINETUNING TRAINING PHASE
    sM = som_seqtrain(sM,sD,'radius',conf.radius, ...
        'msize',conf.msize,'trainlen',conf.finet.trainlen,...
        'trainlen_type','epochs',...
        'lattice',conf.lattice, ...
        'shape',conf.shape, ...
        'alpha_ini', conf.finet.alpha_ini, ...
        'tracking',0);
    [e1,e2,e3]=som_quality(sM,sD);
    fprintf('Final quantization error: %5.3f\n',e1)
    fprintf('Final topographic error:  %5.3f\n',e2)
    fprintf('Final combined error:  %5.3f\n',e3)  
end
sM = som_autolabel(sM,sD,'vote'); %The best matching unit of each sample is found. The label is given to the map unit.

if conf.plot==1
    figure(2)
    colormap(1-gray)
    som_show(sM,'norm','d') %shows map without classes

    figure(3)
    som_show(sM,'umat','all','empty','Labels')
    som_show_add('label',sM,'Textsize',8,'TextColor','r','Subplot',2)
end

%%
% % 
% figure(3)
% colormap(1-gray)
% som_show(sMap,'norm','d')


%sMap  = som_seqtrain(sMap,sD.data,'radius',[5 1],'trainlen',10);
%som_show(sM,'umat','all','comp',1:4,'empty','Labels','norm','d');


%%
f=struct();
f.plot=0;
if f.plot==1
    S = sprintf('%s ', sD.labels{:});
    sD_labels_n= sscanf(S, '%f');
    %%
    figure(1);scatter3(sD.data(:,1),sD.data(:,2),sD.data(:,3),sD_labels_n*100,sD_labels_n*100)
    xlabel('Feature 1: resina-T3')
    ylabel('Feature 2: Tiroxina total')
    zlabel('Feature 3: TSH')
end