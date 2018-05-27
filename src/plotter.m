clc
%clear all
close all

set(0,'defaultAxesFontSize',11)
xlab='Normalization Type';
cats={'var','range','log','logistic','histD','histC'};
c = categorical(cats,'Ordinal',true);
c = reordercats(c,{'var','range','log','logistic','histD','histC'});
xnumeric=0;
%c=[10,25,50,75];
sp_len=1;


% [0.9771999999999998, 0.9764999999999999, 0.9755, 0.9752000000000001]
% [0.0029597297173897513, 0.0025396850198400613, 0.0025000000000000022, 0.0024413111231467426]
% [0.070677250232175, 0.07148836771799252, 0.0732225560568273, 0.07451772938480135]
% [0.0055612760640249784, 0.004581880083607053, 0.004010054383018743, 0.00569740356878188]
% [525.1195837736129, 411.8508449792862, 370.224857378006, 389.8176671266556]
% [94.9800606810703, 48.47875948806978, 57.241606780645384, 30.096442179846306]

acc.avg=results.v(:,3)';
%acc.std=[0.0029597297173897513, 0.0025396850198400613, 0.0025000000000000022, 0.0024413111231467426];

% 1x1 2x2 3x3 4x4
%xlim_val=[-1,5];

figure('rend','painters','pos',[10 10 sp_len*290 300])
subplot(1,sp_len,1)
hold on
bar(c,acc.avg)
%errorbar(c,acc.avg,acc.std,'.-')
m=0.005;
if xnumeric, xlim(xlim_val); end
%ylim([min(acc.avg)-m,max(acc.avg)+m])
xm=6;
%xlim([min(c)-xm,max(c)+xm])
xlabel(xlab)
ylabel('Final Combined Error')
%% loss
acc.avg=[0.070677250232175, 0.07148836771799252, 0.0732225560568273, 0.07451772938480135];
acc.std=[0.0055612760640249784, 0.004581880083607053, 0.004010054383018743, 0.00569740356878188]

subplot(1,sp_len,2)

bar(c,acc.avg)
hold on
errorbar(c,acc.avg,acc.std,'.-')
m=0.008;
ylim([min(acc.avg)-m,max(acc.avg)+m])
%xlim([min(c)-xm,max(c)+xm])
if xnumeric, xlim(xlim_val); end

xlabel(xlab)
ylabel('Loss')


%% time
acc.avg = [542.3437945604325,525.1195837736129, 411.8508449792862, 370.224857378006, 389.8176671266556]
acc.std = [70.36226653967823,94.9800606810703, 48.47875948806978, 57.241606780645384, 30.096442179846306]

subplot(1,sp_len,3)

bar(c,acc.avg)
hold on
errorbar(c,acc.avg,acc.std,'.-')
m=140;
ylim([min(acc.avg)-m,max(acc.avg)+m])
%xlim([min(c)-xm,max(c)+xm])
if xnumeric, xlim(xlim_val); end

xlabel(xlab)
ylabel('Train time [s]')

%% parameter count

acc.avg = [320
9568
18816
29064
37312];
acc.avg=[
    91306;91306;91306;91306;91306];
%    33034;49306;91306;150394];
subplot(1,sp_len,4)

hold on
bar(c,acc.avg)
%errorbar(c,acc.avg,acc.std,'.')
m=0.03*mean(acc.avg);
ylim([min(acc.avg)-m,max(acc.avg)+m])
if xnumeric, xlim(xlim_val); end

%xlim([min(c)-xm,max(c)+xm])
xlabel(xlab)
ylabel('Parameter Count')


%% 

%12 filters
%experiment ID 9 Average results [1.28324774e-01 9.60000000e-01 1.62018404e+02]
%Std results [1.92405315e-02 3.66060104e-03 2.00672143e+01]