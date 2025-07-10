clear variables

%%Input variables:

name='test'; % Add a name for saving output files

Lx=10;    % horizontal length of field
Ly=10;    % vertical length of field
Nbins=10; % No. of bins in each of the x and y directions

N=10000;    % no. of slugs
Tmax=1000; % Maximum time steps
Tint=100;   % Time steps between recording outputs
Nk=1;       % Number of repeated simulations

I0=1; % initial positions: 1 = uniform distribution, 2 = load previous distribution
InitialFile='LastPosition_test.txt'; % if I0 = 2, input file name to load initial position from previous simulation

%Sigma parameters for step sizes
sigs=0.1047; % sparse slugs
sigd=0.1125; % dense slugs

%Movement frequency parameters
MPs=0.5;    % sparse slugs
MPd=0.25;   % dense slugs

%Underground movement parameters
Pui=0.5;    % Initital prob overground
sigu=0.05;     % Step size parameter
MPu=1;      % Movement frequency
MVu=0.5;    % Vertical movement up probability
MVd=0.5;    % Vertical movement down probability

corstr=0.8; % Correlation strength of Von Mises distribution for sparse movement

R=1;                    % Perception radius
DensityLimit = 50;      % Density threshold
dl=DensityLimit*pi*R^2; % Number of slugs within R at the threshold


for k=1:Nk %This for loop can be changed to a parfor loop for parallel simulations

    
    %%initial position
    if I0==1
    Px0=rand(1,N)*Lx; Py0=rand(1,N)*Ly; 
    Pu0=floor(rand(1,N)+Pui);
    th=rand(1,N)*2*pi;
    else 
        if I0==2
            if InitialFile(end-2:end)=='txt'
                T = table2array(readtable(InitialFile));
            else 
            if InitialFile(end-2:end)=='mat'
                T = table2array(load(InitialFile));
            else
                display("error reading initial position file")
            end
            end
            Px0=T(:,1)'; Py0=T(:,2)'; 
            Pu0=T(:,3)'; th=T(:,4)';

        else display("error selecting initial positions")
        end
    end
    
    Px=Px0; Py=Py0; Pu=Pu0;
    Pxh=zeros(Tmax/100,N); Pyh=zeros(Tmax/100,N); Puh=zeros(Tmax/100,N);
    
    %% Random Walk
    for j=1:Tmax

        % Generate new positions for each slug:
        [Px,Py,Pu,th,dw]=nextstep3D(Px,Py,Pu,th,sigs,sigd,sigu,MPd,MPs,corstr,R,MPu,MVu,MVd,Lx,Ly,dl);       
        
        % Position of all animals is recorded at every 100 time steps to
        % record temporal dynamics without a huge data file:
        if mod(j,Tint)==0
            Pxh(j/Tint,:)=Px; Pyh(j/Tint,:)=Py; Puh(j/Tint,:)=Pu;
            dwh(j/Tint)=dw; 

            disp(['Iteration: ',num2str(k),', time: ',num2str(j),' out of ',num2str(Tmax)])
        end
        
    end
    
    X{k}=Pxh; Y{k}=Pyh; U{k}=Puh; % Record the final position of this iteration
    
    Nu(:,k)=sum(U{k}==1,2); Nd(:,k)=sum(U{k}==0,2); % Record the number of slugs above and below ground

end
%%

% Find the correlation coefficient and range between min and max bin counts:
[Corr,Brange] = SlugBinning(Nbins,Lx,Ly,X,Y,U,name);

% If multiple iterations are done then take the average (otherwise ignore):
Corr=mean(Corr,2); Brange=mean(Brange,3); Nu=mean(Nu,2); Nd=mean(Nd,2);

% Write outputs to a table:
Outputs = table(Corr,Brange,Nu,Nd); 
save(['ModelOutputs_',name,'.mat'],'Outputs')
writetable(Outputs,['ModelOutputs_',name,'.txt'])    

%Output final position and angle of movement (if multiple iterations the final one is saved)
Xfin=X{k}(end,:)'; Yfin=Y{k}(end,:)'; Ufin=U{k}(end,:)'; Anglefin=th';
LastPosition = table(Xfin,Yfin,Ufin,Anglefin);
save(['LastPosition_',name,'.mat'],'LastPosition')
writetable(LastPosition,['LastPosition_',name,'.txt'])
