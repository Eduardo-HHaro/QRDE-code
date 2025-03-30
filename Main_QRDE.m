%___ CEC-2017 ITERATOR FOR QUARTILE-BASED RANKED DIFFERENTIAL EVOLUTION ___
%
% _________________________________________________________________________
%
% Authorship by:
% Eduardo H. Haro / Diego Oliva 
%
% eduardo.hernandezh@academicos.udg.mx / ORCID - 0000-0001-7179-5283
% diego.oliva@academicos.udg.mx / ORCID - 0000-0001-8781-7993
%
% _________________________________________________________________________
%
% In this code, the main CEC-2017 iterator is presented for the proposed 
% QRDE algorithm. The code is divided into three parts which are the 
% parameters initialization for the experiments, the processing part where 
% the QRDE is tested on the 30 benchmark functions, and the generation of
% metrics where the obtained results are organized for simplicity of
% reading. Of course, the user can modify any of these parts in order to
% facilitate its procedure or for adding new competitors.

clc
clear

% Iterator parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pop=100;                                % Number of individuals
dim=50;                                 % Number of dimensions
lb=-100;                                % Lower bound
ub=100;                                 % Upper bound
Access=0;                               % Initial function access
Faccess=50000;                          % Final function access
Run=30;                                 % Independent runs

fhd=str2func('cec17_func'); 

Results=[];

QRDE.fit=zeros(30,1); QRDE.Time=zeros(30,1); QRDE.Conv=zeros(30,Faccess);

Results=[Results,QRDE];
data=[Results;Results;Results;Results;Results;Results;Results;Results;Results;Results;...
    Results;Results;Results;Results;Results;Results;Results;Results;Results;Results;...
    Results;Results;Results;Results;Results;Results;Results;Results;Results;Results];

% Iterator processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('________________ITERATOR CEC-2017_________________')

for i=1:30
    fprintf('\n')
    disp(['Objective Function F',num2str(i)])
    
    fprintf('\n'); fprintf('QRDE: ')
    for j=1:Run
        Alg=1;
        varargin=i;
        [Best,Time,Conv]=QRDE_CEC(pop,dim,lb,ub,Access,Faccess,fhd,varargin);   % QRDE
        [data]=Process(Alg,Best,Time,Conv,i,j,data);
        if rem(j,10)==0; fprintf('* '); else; fprintf('*'); end
    end
    
    fprintf('\n')
end

% GENERATION OF METRICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Metrics=zeros(30*3,size(data,2));                   % Table of metrics
Clock=zeros(30,size(data,2));                       % Table of times
Mconv=zeros(30*size(data,2),Faccess);               % Table of convergences

aux1=1;
aux2=2;
aux3=3;

for i=1:30                                              % Analizing each function
    for j=1:size(data,2)                                % Analizing each algorithm
        Metrics(aux1,j)=min(data(i,j).fit(:,1));        % Best result
        Metrics(aux2,j)=mean(data(i,j).fit(:,1));       % Average result
        Metrics(aux3,j)=std(data(i,j).fit(:,1));        % Standard deviation
        
        Clock(i,j)=mean(data(i,j).Time(:,1));           % Computational time
        
        if i==1
            aux4=j;
        elseif i>1
            aux4=j+(size(data,2)*(i-1));
        end
        
        for k=1:Faccess
            Mconv(aux4,k)=mean(data(i,j).Conv(:,k));    % Average convergence rates
        end
    end
    
    aux1=aux1+3;
    aux2=aux2+3;
    aux3=aux3+3;
end