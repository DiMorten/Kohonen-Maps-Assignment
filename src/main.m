%% Read Data

close all
clc
clear all

% ================= Read Data ================================
addpath(genpath('/home/jorg/Documents/Master/scnd_semester/neural_nets/homework2/repo/src/plotSpread'))
addpath(genpath('SOM-Toolbox-master'));
in_filename='../data/new-thyroid.data';
%sD = som_read_data(in_filename);
sD = som_read_data(in_filename);

% ================ Default Configuration ====================
conf=struct();

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
%conf.shape='cyl';
conf.normalization='log';
% SEARCH BEGINS
conf.lattice='hexa';
%conf.lattice='rect';

conf.dlen=size(sD.data,1);
%conf.algorithm='batch';

conf.plot=0;
conf.manytimes.times=100;
conf.manytimes.e=struct();
conf.manytimes.e.v=zeros(conf.manytimes.times,3);
results=struct();

% ============ Select Experiment ID ====================
conf.exp_id=5;
% ============ Configure Experiment ====================
if conf.exp_id==3 % Topology
    [sD,sM,results] = som_train_topology(sD,conf,results);
elseif conf.exp_id==4 % Normalization
    conf.exp_data={'var','range','log','logistic','histD','histC'};
elseif conf.exp_id==5 % Rough train length
    conf.exp_data=[1,2,3,4,6,20];
end
conf.exp_len=length(conf.exp_data);
results.v=zeros(conf.exp_len,3);
results.exp_data=conf.exp_data;

% ============ Execute Experiment ====================

for i=1:conf.exp_len
    if conf.exp_id==4
        conf.normalization=conf.exp_data{i}
    elseif conf.exp_id==5
        conf.rough.trainlen=conf.exp_data(i)
    end
    [sD,sM,conf] = som_train_many(sD,conf);
    results.v(i,:)=conf.manytimes.e.min;
        
end

%%
%Use: [sD,sM,results] = som_train_topology(sD,conf,results)
function [sD,sM,results] = som_train_topology(sD,conf,results)

count=0;
for i=1:2
    for k=1:3
        count=count+1;
        if i==1, conf.lattice='hexa'; else, conf.lattice='rect'; end
        
        if k==1, conf.shape='sheet'; 
        elseif k==2, conf.shape='cyl'; 
        elseif k==3, conf.shape='toroid'; 
        end
         
        %hexa:sheet,cyl,toroid,rect:sheet,cyl,toroid
        
        [sD,sM,conf] = som_train_many(sD,conf);
        results.v(count,:)=conf.manytimes.e.min;
        results.e1(i,k)=conf.manytimes.e.min(1,1);
        results.e2(i,k)=conf.manytimes.e.min(1,2);
        results.e3(i,k)=conf.manytimes.e.min(1,3);
        
        results.lattice(:,count)=i;
        results.shape(:,count)=k;
        
    end
end
% figure,subplot(1,3,1),mesh(results.e1);
% subplot(1,3,2),mesh(results.e2);
% subplot(1,3,3),mesh(results.e3);
%%
catsx={'hexa','rect'};
catsy={'sheet','cyl','toroid'};
z=results.e3';
mesh3d(catsx,catsy,z,1);hold on;
xlabel('Lattice')
ylabel('Shape')
zlabel('Combined Error')
figure();bar3(z)
xlabel('Lattice')
ylabel('Shape')
zlabel('Combined Error')
set(gca, 'XTickLabel', catsx)
set(gca, 'YTickLabel', catsy)
zlim([0.17,0.185])
end
%%
function mesh3d(catsx,catsy,z,categorical_flag)
if categorical_flag==1
    c = categorical(catsx,'Ordinal',true);
    xcataxis = reordercats(c,catsx);
    c = categorical(catsy,'Ordinal',true);
    ycataxis = reordercats(c,catsy);
    [X,Y]=meshgrid(xcataxis,ycataxis);
    figure,mesh(X,Y,z);    
end
end
%%
function [sD,sM,conf] = som_train_many(sD,conf)

for i=1:1:conf.manytimes.times
    [sD,sM,e]=som_train_once(sD,conf);
    conf.manytimes.e.v(i,:)=e';
   
end
for k=1:3
    conf.manytimes.e.mean(1,k)=mean(conf.manytimes.e.v(:,k));
    conf.manytimes.e.median(1,k)=median(conf.manytimes.e.v(:,k));
    conf.manytimes.e.std(1,k)=std(conf.manytimes.e.v(:,k));
    conf.manytimes.e.min(1,k)=min(conf.manytimes.e.v(:,k));
    
end
if conf.plot==3
    plotSpread(conf.manytimes.e.v(:,1))
    plotSpread(conf.manytimes.e.v(:,2))
    plotSpread(conf.manytimes.e.v(:,3))
end
end
%%
function [sD,sM,e] = som_train_once(sD,conf)
sD = som_normalize(sD,conf.normalization);
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
    %fprintf('Final quantization error: %5.3f\n',e1)
    %fprintf('Final topographic error:  %5.3f\n',e2)
    %fprintf('Final combined error:  %5.3f\n',e3)  

    %sM = som_batchtrain(sM,sD,'radius',conf.radius, ...
    % FINETUNING TRAINING PHASE
    sM = som_seqtrain(sM,sD,'radius',conf.radius, ...
        'msize',conf.msize,'trainlen',conf.finet.trainlen,...
        'trainlen_type','epochs',...
        'lattice',conf.lattice, ...
        'shape',conf.shape, ...
        'alpha_ini', conf.finet.alpha_ini, ...
        'tracking',0);
    [e(1,1),e(1,2),e(1,3)]=som_quality(sM,sD);
    %fprintf('Final quantization error: %5.3f\n',e(1,1))
    %fprintf('Final topographic error:  %5.3f\n',e(1,2))
    %fprintf('Final combined error:  %5.3f\n',e(1,3))  
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
end