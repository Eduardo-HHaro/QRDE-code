%______________________ PROCESSING OF METRIC RESULTS ______________________
% 
% _________________________________________________________________________
%
% Authorship by:
% Eduardo H. Haro / Diego Oliva / Angel Casas-Ordaz
%
% eduardo.hernandezh@academicos.udg.mx / ORCID - 0000-0001-7179-5283
% diego.oliva@academicos.udg.mx / ORCID - 0000-0001-8781-7993
% angel.casas5699@alumnos.udg.mx / ORCID - 0009-0005-7711-7551
%
% _________________________________________________________________________
%
% In this code, the obtained results of the algorithm are placed correctly
% organized on the "Data" structure. If the user decides to add another
% algorithm to the competition, it is just necessary to follow the same
% sintax of "case 1" and doing the respective simple modifications to the 
% first two parts of the main iterator.

function[data]=Process(Alg,Best,Time,Conv,i,j,data)

switch Alg
    case 1                                  % QRDE
        data(i,1).fit(j,1)=Best;
        data(i,1).Time(j,1)=Time;
        data(i,1).Conv(j,:)=Conv(1,:);
end

