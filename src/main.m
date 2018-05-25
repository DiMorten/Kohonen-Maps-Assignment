%% Read Data

close all
clc

in_filename='../data/new-thyroid.data';
%sD = som_read_data(in_filename);
sD = som_read_data(in_filename);

conf=struct();
conf.size=[10 15];
conf.type='hexa';

%%

sD = som_normalize(sD,'range');
sM = som_make(sD);
sM = som_autolabel(sM,sD,'vote'); %The best matching unit of each sample is found. The label is given to the map unit.
figure(2)
colormap(1-gray)
som_show(sM,'norm','d') %shows map without classes


% % 
% figure(3)
% colormap(1-gray)
% som_show(sMap,'norm','d')

figure(3)
som_show(sM,'umat','all','empty','Labels')
som_show_add('label',sM,'Textsize',8,'TextColor','r','Subplot',2)

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