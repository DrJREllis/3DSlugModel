function [Px,Py,Pu,th,dw]=nextstep3D(Px,Py,Pu,th,sigs,sigd,sigu,MPd,MPs,corstr,R,MPu,MVu,MVd,Lx,Ly,dl)

Np=size(Px,2);
Delx=zeros(1,Np); Dely=zeros(1,Np);

%Calculate a distance matrix of all animals overground
Pxo=Px; Pxo(Pu==0)=nan;
Pyo=Py; Pyo(Pu==0)=nan;
dists=pdist2([Pxo' Pyo'],[Pxo' Pyo']);

%% Vertical movement
Vm=zeros(1,Np);
Vmu=rand(1,sum(Pu==0))<MVu; Vmd=rand(1,sum(Pu==1))<MVd;

Vm(Pu==0)=Vmu; Vm(Pu==1)=-Vmd;
Pu=Pu+Vm; % Update locations
ss(Vm~=0)=0; % set horizontal movement length to 0


%% Find animals in sparse, dense and underground space
sparse = sum(dists<=R) < dl;
sparseind=find( sparse==1 & Pu==1 & Vm==0);
denseind=find( sparse==0 & Pu==1 & Vm==0);
undind=find(Pu==0 & Vm==0);
dw=size(denseind,2);
uw=size(undind,2);


%% Underground movement
pwu=1/(1-MPu);
ss(undind)=abs(randn(uw,1)*sigu); %Generate step size
th(undind)=rand(uw,1)*2*pi-pi; %Generate direction of movement

ss(undind)=ss(undind).*(rand(uw,1)*pwu-1>=0)'; %Generate non-movers

Delx(undind)=ss(undind).*cos(th(undind)); %step length in x direction
Dely(undind)=ss(undind).*sin(th(undind)); %step length in y direction 



%% Sparse movement

pws=1/(1-MPs);

ss(sparseind)=abs(randn(size(sparseind,2),1)*sigs); %Generate step size
for i=sparseind
    th(i)=circ_vmrnd(th(i),corstr,1); %Generate direction of movement
    if rand*pws-1>=0
        ss(i)=0; %Generate non-movers
    end
end


Delx(sparseind)=ss(sparseind).*cos(th(sparseind)); %step length in x direction
Dely(sparseind)=ss(sparseind).*sin(th(sparseind)); %step length in y direction 


%% Dense movement
pwd=1/(1-MPd);
ss(denseind)=abs(randn(dw,1)*sigd); %Generate step size
th(denseind)=rand(dw,1)*2*pi-pi; %Generate direction of movement

ss(denseind)=ss(denseind).*(rand(dw,1)*pwd-1>=0)'; %Generate non-movers

Delx(denseind)=ss(denseind).*cos(th(denseind)); %step length in x direction
Dely(denseind)=ss(denseind).*sin(th(denseind)); %step length in y direction 


%% Boundary conditions

%For animals that move outside a boundary, the step is regenerated
ind2=find((Px+Delx > Lx) | (Px+Delx < 0) | (Py+Dely > Ly) | (Py+Dely < 0));    
for i=ind2
    while (Px(i)+Delx(i) > Lx) || (Px(i)+Delx(i) < 0) || (Py(i)+Dely(i) > Ly) || (Py(i)+Dely(i) < 0)  %closed boundary      
        
        if ismember(i,sparseind)==1
            th(i)=circ_vmrnd(th(i),corstr,1);
            ss(i)=abs(randn*sigs); 
        else 
            if ismember(i,denseind)==1
                th(i)=rand*2*pi-pi;
                ss(i)=abs(randn*sigd); 
            else 
                if ismember(i,undind)==1
                    th(i)=rand*2*pi-pi;
                    ss(i)=abs(randn*sigu); 
                end
            end
        end
        Delx(i)=ss(i).*cos(th(i)); %step length in x direction
        Dely(i)=ss(i).*sin(th(i)); %step length in y direction 
    end   
end

%% Calculate new positions
Px=Px+Delx;
Py=Py+Dely;
