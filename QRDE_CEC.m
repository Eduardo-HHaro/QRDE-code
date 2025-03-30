%__________ QUARTILE-BASED RANKED DIFFERENTIAL EVOLUTION (QRDE) ___________
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
% In this code, the QRDE algorithm is expose. It is composed of four main 
% stages which are the initialization, the mutation, the crossover and the 
% proposed quartile-based selection. It the user wants to include another 
% approach to the competition, it is just necessary that his scheme offers
% the best obtained fitnes value (Best), the computational expended time 
% (Time), and the convergence rate of the run (Conv).

function[Best,Time,Conv]=QRDE_CEC(pop,dim,lb,ub,Access,Faccess,fhd,varargin)

tic
% INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F=0.8;                                             % Scaling factor
Cr=0.2;                                            % Crossover rate

x=lb+(ub-lb).*rand(pop,dim);                       % Initialization

Best=inf;                                          % Current best
pbest=zeros(1,dim);                                % Best position
Conv=zeros(1,Faccess);                             % Convergence array

Fit=zeros(pop,1);                                  % Fitness array

for i=1:pop
    Fit(i)=feval(fhd,x(i,:)',varargin{:});         % Evaluation
    Access=Access+1;                               % Update function access
    
    if Fit(i)<Best                             
        Best=Fit(i);                               % Update current best
        pbest(1,:)=x(i,:);                         % Update best position
    end
    
    Conv(1,Access)=Best;                           % Update convergence
end

while Access<Faccess                               % Stop criteria
    for i=1:pop
        
        % DE/RAND/1 MUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        A=randperm(pop);                           % Definition of 3 random individuals
        r1=x(A(1),:);
        r2=x(A(2),:);
        r3=x(A(3),:);
        
        xm=r1+F*(r2-r3);                           % Mutant individual
        
        % BINOMIAL CROSSOVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xc=zeros(1,dim);                           % Trial array
        
        for j=1:dim
            r4=rand();
            r5=round(1+(dim-1).*rand(1,1));
            
            if r4<=Cr || r5==j
                xc(1,j)=xm(1,j);                   % Trial vector is filled with mutant individual 
            else
                xc(1,j)=x(i,j);                    % Trial vector is filled with current individual
            end
            
            if xc(1,j)>ub
                xc(1,j)=ub;                        % Checking upper bounds
            elseif xc(1,j)<lb
                xc(1,j)=lb;                        % Checking lower bounds
            end
        end
        
        % QUARTILE-BASED SELECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        xt=[x Fit];
        xt=sortrows(xt,dim+1);                     % Sort current population
        
        MP2=mean(xt(:,dim+1));                     % Calculation of Q2
        
        for j=1:pop
            if xt(j,dim+1)>=MP2
                Q2_pos=j;                          % Position of Q2
                break;
            end
        end
        
        xv1=xt(1:Q2_pos-1,:);                      % Population of first section
        MP1=mean(xv1(:,dim+1));                    % Calculation of Q1
        
        for j=1:size(xv1,1)
            if xv1(j,dim+1)>=MP1
                Q1_pos=j;                          % Position of Q1
                break;
            end
        end
        
        xv2=xt(Q2_pos:end,:);                      % Population of second section
        MP3=mean(xv2(:,dim+1));                    % Calculation of Q3
        
        for j=1:size(xv2,1)
            if xv2(j,dim+1)>=MP3
                Q3_pos=j+(Q2_pos-1);               % Position of Q3
                break;
            end
        end
        
        Qv1=xt(1:Q1_pos,:);                        % Group 1
        Qv2=xt(Q1_pos+1:Q2_pos,:);                 % Group 2
        Qv3=xt(Q2_pos+1:Q3_pos,:);                 % Group 3
        Qv4=xt(Q3_pos+1:pop,:);                    % Group 4
        
        if size(Qv4,1)<3
            Qv4=[Qv3(end,:);Qv4(:,:)];             % Qv4 must always have at least 3 individuals
            Qv3=Qv3(1:end-1,:);
        end
        if size(Qv3,1)<3
            Qv3=[Qv2(end,:);Qv3(:,:)];             % Qv3 must always have at least 3 individuals
            Qv2=Qv2(1:end-1,:);
        end
        if size(Qv2,1)<3
            Qv2=[Qv1(end,:);Qv2(:,:)];             % Qv2 must always have at least 3 individuals
            Qv1=Qv1(1:end-1,:);
        end
        
        if Access<=pop
            Fa=size(Qv4,1);                        % Constant factor for alpha
            alpha=1;                               % Scaling factor
        elseif Access>pop
            Fx=size(Qv4,1);
            aux=abs(((Fx*100)/Fa)/100);
            alpha=1-aux;                           % Updating scaling factor
        end
        if alpha<=0.1
            alpha=0.1;                             % Lower feasible value for alpha
        end
        
        New_fit=feval(fhd,xc(1,:)',varargin{:});   % Evaluation of trial vector
        Access=Access+1;                           % Update function access
        
        if New_fit<Best
            Best=New_fit;                          % Update current best
            pbest(1,:)=xc(1,:);                    % Update best position
        end
        
        Conv(1,Access)=Best;                       % Update convergence
        
        Raux=rand();                               % Random number
        
        if Raux<=alpha                             % Exploitation
            R_pos=round(1+(size(Qv4,1)-1).*rand(1,1)); 
            XQv4=Qv4(R_pos,:);                     % Select a random individual from group 4

            if New_fit<XQv4(1,dim+1)               % Comparison between Xc and XQv4
                Qv4(R_pos,1:dim)=xc(1,:);
                Qv4(R_pos,dim+1)=New_fit;
            elseif New_fit==XQv4(1,dim+1)          
                R_pos=round(1+(size(Qv3,1)-1).*rand(1,1)); 
                Qv3(R_pos,1:dim)=xc(1,:);          % Select a random individual from group 3
                Qv3(R_pos,dim+1)=New_fit;
            end
        end
        
        x=[Qv1(:,1:dim);Qv2(:,1:dim);Qv3(:,1:dim);Qv4(:,1:dim)];
        Fit=[Qv1(:,dim+1);Qv2(:,dim+1);Qv3(:,dim+1);Qv4(:,dim+1)];
        
        if Raux>alpha                              % Exploration
            if New_fit>Fit(i,1)                    % Trial vector is compared with current Xi
                Fit(i,1)=New_fit;
                x(i,:)=xc(1,:);
            end
        end
    end
end

Time=toc;                                          % Computational time